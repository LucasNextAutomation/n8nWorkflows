import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase'

// Webhook secret for validation
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET

export async function POST(request: NextRequest) {
  try {
    // Validate webhook secret
    const secret = request.headers.get('x-webhook-secret')
    if (secret !== WEBHOOK_SECRET) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const body = await request.json()
    const { event, ...payload } = body

    console.log(`[Webhook] Received event: ${event}`)

    const supabase = createServiceClient()

    // Log the webhook
    await supabase.from('webhook_logs').insert({
      event_type: event,
      payload: payload,
      run_id: payload.run_id,
      status: 'received',
    })

    // Handle different event types
    switch (event) {
      case 'run_started':
        await handleRunStarted(supabase, payload)
        break

      case 'posts_scraped':
        await handlePostsScraped(supabase, payload)
        break

      case 'analysis_complete':
        await handleAnalysisComplete(supabase, payload)
        break

      case 'generation_complete':
        await handleGenerationComplete(supabase, payload)
        break

      case 'run_complete':
        await handleRunComplete(supabase, payload)
        break

      default:
        console.warn(`[Webhook] Unknown event type: ${event}`)
    }

    // Update webhook log status
    await supabase
      .from('webhook_logs')
      .update({ status: 'processed', processed_at: new Date().toISOString() })
      .eq('event_type', event)
      .eq('run_id', payload.run_id)

    return NextResponse.json({
      success: true,
      message: 'Webhook received',
      event,
    })
  } catch (error: any) {
    console.error('[Webhook] Error:', error)

    return NextResponse.json(
      {
        error: 'Internal server error',
        message: error.message,
      },
      { status: 500 }
    )
  }
}

async function handleRunStarted(supabase: any, payload: any) {
  const { run_id, creators_count, timestamp } = payload

  await supabase.from('automation_runs').insert({
    id: run_id,
    status: 'running',
    started_at: timestamp,
    creators_total: creators_count,
  })

  console.log(`[Webhook] Run ${run_id} started`)
}

async function handlePostsScraped(supabase: any, payload: any) {
  const { run_id, posts } = payload

  if (!posts || posts.length === 0) {
    console.warn('[Webhook] No posts to insert')
    return
  }

  // Insert posts
  const postsToInsert = posts.map((post: any) => ({
    creator_id: post.creator_id,
    post_url: post.post_url,
    post_text: post.post_text,
    posted_date: post.posted_date,
    likes_count: post.likes_count || 0,
    comments_count: post.comments_count || 0,
    content_type: post.content_type,
    scraped_at: new Date().toISOString(),
  }))

  const { error } = await supabase.from('posts').upsert(postsToInsert, {
    onConflict: 'post_url',
    ignoreDuplicates: false,
  })

  if (error) {
    console.error('[Webhook] Error inserting posts:', error)
  }

  // Update run stats
  await supabase
    .from('automation_runs')
    .update({
      posts_scraped: posts.length,
    })
    .eq('id', run_id)

  console.log(`[Webhook] Inserted ${posts.length} posts for run ${run_id}`)
}

async function handleAnalysisComplete(supabase: any, payload: any) {
  const { run_id, analyzed_posts } = payload

  if (!analyzed_posts || analyzed_posts.length === 0) {
    console.warn('[Webhook] No analyzed posts')
    return
  }

  // Update posts with AI scores
  for (const post of analyzed_posts) {
    await supabase
      .from('posts')
      .update({
        relevance_score: post.relevance_score,
        value_depth_score: post.value_depth_score,
        tone_suitable: post.tone_suitable,
        final_score: post.final_score,
        topic_category: post.topic_category,
        content_pillar: post.content_pillar,
        lead_magnet_opportunity: post.lead_magnet_opportunity,
        lead_magnet_suggestion: post.lead_magnet_suggestion,
        ai_reasoning: post.ai_reasoning,
        is_analyzed: true,
        analyzed_at: new Date().toISOString(),
      })
      .eq('id', post.post_id)
  }

  // Update run stats
  await supabase
    .from('automation_runs')
    .update({
      posts_analyzed: analyzed_posts.length,
    })
    .eq('id', run_id)

  console.log(`[Webhook] Updated ${analyzed_posts.length} posts with AI scores`)
}

async function handleGenerationComplete(supabase: any, payload: any) {
  const { run_id, generated_posts } = payload

  if (!generated_posts || generated_posts.length === 0) {
    console.warn('[Webhook] No generated posts')
    return
  }

  // Insert generated posts
  const postsToInsert = generated_posts.map((post: any, index: number) => ({
    run_id,
    original_post_id: post.original_post_id,
    rank: index + 1,
    generated_text: post.generated_text,
    inspiration_creator: post.creator_name,
    inspiration_url: post.original_url,
    original_relevance: post.relevance_score,
    original_value_depth: post.value_depth_score,
    original_final_score: post.final_score,
    topic_category: post.topic_category,
    content_pillar: post.content_pillar,
    lead_magnet_suggestion: post.lead_magnet_suggestion,
    status: 'draft',
  }))

  const { error } = await supabase.from('generated_posts').insert(postsToInsert)

  if (error) {
    console.error('[Webhook] Error inserting generated posts:', error)
  }

  // Update run stats
  await supabase
    .from('automation_runs')
    .update({
      posts_generated: generated_posts.length,
    })
    .eq('id', run_id)

  // Mark original posts as selected for generation
  const originalPostIds = generated_posts.map((p: any) => p.original_post_id).filter(Boolean)
  if (originalPostIds.length > 0) {
    await supabase
      .from('posts')
      .update({ is_selected_for_generation: true })
      .in('id', originalPostIds)
  }

  console.log(`[Webhook] Inserted ${generated_posts.length} generated posts`)
}

async function handleRunComplete(supabase: any, payload: any) {
  const { run_id, status, stats, outputs, errors } = payload

  const completedAt = new Date().toISOString()
  const startedAtResult = await supabase
    .from('automation_runs')
    .select('started_at')
    .eq('id', run_id)
    .single()

  let durationSeconds = null
  if (startedAtResult.data?.started_at) {
    const startTime = new Date(startedAtResult.data.started_at).getTime()
    const endTime = new Date(completedAt).getTime()
    durationSeconds = Math.floor((endTime - startTime) / 1000)
  }

  await supabase
    .from('automation_runs')
    .update({
      status: status || 'completed',
      completed_at: completedAt,
      duration_seconds: durationSeconds,
      creators_scraped: stats?.creators_scraped,
      creators_failed: stats?.creators_failed,
      posts_filtered: stats?.posts_filtered,
      openai_calls: stats?.openai_calls,
      openai_tokens_used: stats?.openai_tokens_used,
      openai_cost_usd: stats?.openai_cost_usd,
      apify_calls: stats?.apify_calls,
      apify_credits_used: stats?.apify_credits_used,
      apify_cost_usd: stats?.apify_cost_usd,
      google_sheet_url: outputs?.google_sheet_url,
      google_drive_pdf_url: outputs?.google_drive_pdf_url,
      errors: errors || [],
    })
    .eq('id', run_id)

  // Aggregate daily analytics
  const today = new Date().toISOString().split('T')[0]
  await supabase.rpc('aggregate_daily_analytics', { target_date: today })

  console.log(`[Webhook] Run ${run_id} completed with status: ${status}`)
}
