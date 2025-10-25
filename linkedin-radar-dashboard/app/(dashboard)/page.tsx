'use client'

import { useQuery } from '@tanstack/react-query'
import {
  TrendingUp,
  Users,
  FileText,
  BarChart3,
  Calendar,
  Sparkles,
  ArrowRight,
  RefreshCw,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Progress } from '@/components/ui/progress'
import { Badge } from '@/components/ui/badge'
import { formatNumber, formatDate } from '@/lib/utils'

// Mock data - replace with actual API calls
const mockData = {
  stats: {
    activeCreators: 25,
    postsAnalyzed: 147,
    avgEngagement: 1245,
    postsGenerated: 7,
  },
  strategy: [
    { pillar: 'Educational', target: 2, current: 2, color: '#8B5CF6' },
    { pillar: 'Technical', target: 2, current: 1, color: '#06B6D4' },
    { pillar: 'Personal', target: 1, current: 1, color: '#EC4899' },
    { pillar: 'Story', target: 1, current: 1, color: '#F59E0B' },
    { pillar: 'Promotional', target: 1, current: 0, color: '#10B981' },
  ],
  suggestions: [
    {
      id: 1,
      title: 'How AI is transforming content creation',
      pillar: 'Educational',
      score: 24,
      daysAgo: 1,
    },
    {
      id: 2,
      title: 'Our automation journey: 200+ hours saved',
      pillar: 'Story',
      score: 23,
      daysAgo: 2,
    },
    {
      id: 3,
      title: 'Technical deep-dive: Building LinkedIn scrapers',
      pillar: 'Technical',
      score: 22,
      daysAgo: 3,
    },
  ],
  knowledgeBase: {
    creatorsTracked: 25,
    postsStored: 1847,
    completeness: 78,
  },
  lastRun: {
    date: new Date().toISOString(),
    status: 'completed',
    duration: '42min',
  },
}

export default function DashboardPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['dashboard-overview'],
    queryFn: async () => {
      // Replace with actual API call
      await new Promise((resolve) => setTimeout(resolve, 1000))
      return mockData
    },
  })

  if (isLoading) {
    return (
      <div className="flex h-full items-center justify-center">
        <RefreshCw className="h-8 w-8 animate-spin text-primary" />
      </div>
    )
  }

  const stats = data?.stats || mockData.stats

  return (
    <div className="h-full overflow-y-auto p-8 space-y-8">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Welcome back to <span className="gradient-text">LinkedIn Radar</span>
          </h1>
          <p className="text-muted-foreground mt-1">
            Your weekly content intelligence dashboard
          </p>
        </div>
        <Button className="bg-gradient-scripe">
          <Sparkles className="mr-2 h-4 w-4" />
          Trigger Automation
        </Button>
      </div>

      {/* Performance Snapshot */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        <Card className="card-hover">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Creators</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.activeCreators}</div>
            <p className="text-xs text-muted-foreground">
              Tracking LinkedIn profiles
            </p>
          </CardContent>
        </Card>

        <Card className="card-hover">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Posts Analyzed</CardTitle>
            <FileText className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.postsAnalyzed}</div>
            <p className="text-xs text-muted-foreground">
              This week
            </p>
          </CardContent>
        </Card>

        <Card className="card-hover">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Avg Engagement</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatNumber(stats.avgEngagement)}</div>
            <p className="text-xs text-emerald-500 flex items-center">
              <TrendingUp className="mr-1 h-3 w-3" />
              +12.5% from last week
            </p>
          </CardContent>
        </Card>

        <Card className="card-hover">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Posts Generated</CardTitle>
            <BarChart3 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.postsGenerated}</div>
            <p className="text-xs text-muted-foreground">
              Ready to publish
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Content Strategy Tracker */}
        <Card>
          <CardHeader>
            <CardTitle>Content Strategy Tracker</CardTitle>
            <CardDescription>
              Target frequency vs actual posts this week
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {data?.strategy.map((pillar) => (
              <div key={pillar.pillar} className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <div className="flex items-center space-x-2">
                    <div
                      className="h-3 w-3 rounded-full"
                      style={{ backgroundColor: pillar.color }}
                    />
                    <span className="font-medium">{pillar.pillar}</span>
                  </div>
                  <span className="text-muted-foreground">
                    {pillar.current}/{pillar.target}
                  </span>
                </div>
                <Progress
                  value={(pillar.current / pillar.target) * 100}
                  className="h-2"
                  style={
                    {
                      '--progress-background': pillar.color,
                    } as React.CSSProperties
                  }
                />
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Knowledge Base Status */}
        <Card>
          <CardHeader>
            <CardTitle>Knowledge Base Status</CardTitle>
            <CardDescription>
              System learning completeness
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Completeness Ring */}
            <div className="flex items-center justify-center">
              <div className="relative h-40 w-40">
                <svg className="h-full w-full -rotate-90 transform">
                  <circle
                    cx="80"
                    cy="80"
                    r="70"
                    stroke="currentColor"
                    strokeWidth="10"
                    fill="transparent"
                    className="text-muted"
                  />
                  <circle
                    cx="80"
                    cy="80"
                    r="70"
                    stroke="url(#gradient)"
                    strokeWidth="10"
                    fill="transparent"
                    strokeDasharray={`${2 * Math.PI * 70}`}
                    strokeDashoffset={`${
                      2 * Math.PI * 70 * (1 - (data?.knowledgeBase.completeness || 0) / 100)
                    }`}
                    strokeLinecap="round"
                    className="transition-all duration-1000"
                  />
                  <defs>
                    <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop offset="0%" stopColor="#667eea" />
                      <stop offset="100%" stopColor="#764ba2" />
                    </linearGradient>
                  </defs>
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <span className="text-3xl font-bold">
                    {data?.knowledgeBase.completeness}%
                  </span>
                  <span className="text-xs text-muted-foreground">Complete</span>
                </div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <p className="text-sm text-muted-foreground">Creators Tracked</p>
                <p className="text-2xl font-bold">{data?.knowledgeBase.creatorsTracked}</p>
              </div>
              <div className="space-y-1">
                <p className="text-sm text-muted-foreground">Posts Stored</p>
                <p className="text-2xl font-bold">
                  {formatNumber(data?.knowledgeBase.postsStored || 0)}
                </p>
              </div>
            </div>

            <Button variant="outline" className="w-full">
              <FileText className="mr-2 h-4 w-4" />
              Add Knowledge Sources
            </Button>
          </CardContent>
        </Card>
      </div>

      {/* Weekly Suggestions */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Weekly Personalized Suggestions</CardTitle>
              <CardDescription>
                AI-generated post ideas based on top-performing content
              </CardDescription>
            </div>
            <Button variant="ghost" size="sm">
              View All <ArrowRight className="ml-2 h-4 w-4" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-3">
            {data?.suggestions.map((suggestion) => (
              <Card key={suggestion.id} className="card-hover cursor-pointer">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <Badge variant="outline">{suggestion.pillar}</Badge>
                    <span className="text-xs text-muted-foreground">
                      {suggestion.daysAgo}d ago
                    </span>
                  </div>
                </CardHeader>
                <CardContent>
                  <h3 className="font-medium line-clamp-2 mb-3">{suggestion.title}</h3>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-1">
                      <BarChart3 className="h-4 w-4 text-primary" />
                      <span className="text-sm font-medium">Score: {suggestion.score}</span>
                    </div>
                    <Button variant="ghost" size="sm">
                      Open Draft
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Last Automation Run */}
      <Card>
        <CardHeader>
          <CardTitle>Last Automation Run</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Calendar className="h-8 w-8 text-muted-foreground" />
              <div>
                <p className="font-medium">{formatDate(data?.lastRun.date || new Date())}</p>
                <p className="text-sm text-muted-foreground">
                  Completed in {data?.lastRun.duration}
                </p>
              </div>
            </div>
            <Badge className="badge-success">Completed</Badge>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
