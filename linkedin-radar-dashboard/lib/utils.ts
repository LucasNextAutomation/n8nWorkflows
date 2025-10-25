import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatDate(date: string | Date): string {
  const d = new Date(date)
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  }).format(d)
}

export function formatDateTime(date: string | Date): string {
  const d = new Date(date)
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(d)
}

export function formatRelativeTime(date: string | Date): string {
  const now = new Date()
  const then = new Date(date)
  const diffInSeconds = Math.floor((now.getTime() - then.getTime()) / 1000)

  if (diffInSeconds < 60) return 'just now'
  if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`
  if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`
  if (diffInSeconds < 604800) return `${Math.floor(diffInSeconds / 86400)}d ago`
  return formatDate(date)
}

export function formatNumber(num: number): string {
  if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`
  return num.toString()
}

export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

export function formatPercentage(value: number, total: number): string {
  if (total === 0) return '0%'
  return `${Math.round((value / total) * 100)}%`
}

export function calculateEngagementScore(likes: number, comments: number): number {
  // Weight comments 2x more than likes
  return likes + comments * 2
}

export function getScoreColor(score: number, maxScore = 25): string {
  const percentage = (score / maxScore) * 100
  if (percentage >= 80) return 'text-emerald-500'
  if (percentage >= 60) return 'text-blue-500'
  if (percentage >= 40) return 'text-yellow-500'
  return 'text-red-500'
}

export function getScoreBadgeVariant(
  score: number,
  maxScore = 25
): 'success' | 'warning' | 'error' | 'default' {
  const percentage = (score / maxScore) * 100
  if (percentage >= 80) return 'success'
  if (percentage >= 60) return 'default'
  if (percentage >= 40) return 'warning'
  return 'error'
}

export function getStatusColor(status: string): string {
  const statusColors: Record<string, string> = {
    active: 'text-emerald-500',
    running: 'text-blue-500',
    completed: 'text-emerald-500',
    failed: 'text-red-500',
    partial: 'text-yellow-500',
    paused: 'text-gray-500',
    archived: 'text-gray-400',
    draft: 'text-gray-400',
    scheduled: 'text-blue-500',
    published: 'text-emerald-500',
    reviewed: 'text-purple-500',
  }
  return statusColors[status.toLowerCase()] || 'text-gray-500'
}

export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text
  return `${text.substring(0, maxLength)}...`
}

export function extractHashtags(text: string): string[] {
  const regex = /#[\w\u0590-\u05ff]+/g
  return text.match(regex) || []
}

export function calculateReadingTime(text: string): number {
  const wordsPerMinute = 200
  const wordCount = text.trim().split(/\s+/).length
  return Math.ceil(wordCount / wordsPerMinute)
}

export function getTopicCategoryColor(category: string): string {
  const colors: Record<string, string> = {
    'AI Trends': '#8B5CF6',
    'Automation': '#06B6D4',
    'Productivity': '#F59E0B',
    'Entrepreneurship': '#EC4899',
    'Technical': '#10B981',
    'Marketing': '#EF4444',
    'Business': '#3B82F6',
  }
  return colors[category] || '#6B7280'
}

export function getPillarColor(pillar: string): string {
  const colors: Record<string, string> = {
    Educational: '#8B5CF6',
    Personal: '#EC4899',
    Technical: '#06B6D4',
    Story: '#F59E0B',
    Promotional: '#10B981',
  }
  return colors[pillar] || '#6B7280'
}

export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch (error) {
    console.error('Failed to copy:', error)
    return false
  }
}

export function downloadAsFile(content: string, filename: string, type = 'text/plain') {
  const blob = new Blob([content], { type })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

export function parseLinkedInUrl(url: string): { username: string | null; isValid: boolean } {
  try {
    const regex = /linkedin\.com\/in\/([a-zA-Z0-9-]+)/
    const match = url.match(regex)
    return {
      username: match ? match[1] : null,
      isValid: !!match,
    }
  } catch {
    return { username: null, isValid: false }
  }
}

export function generateRunId(): string {
  return `run_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`
}

export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}
