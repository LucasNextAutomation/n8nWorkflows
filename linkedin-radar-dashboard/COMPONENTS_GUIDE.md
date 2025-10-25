# 🎨 Component Library Guide

## Overview

This project uses **shadcn/ui** for the component library. shadcn/ui is NOT an npm package - it's a collection of copy-paste components that you add to your project.

---

## 🚀 Setup shadcn/ui

### 1. Initialize shadcn/ui

```bash
npx shadcn-ui@latest init
```

When prompted, choose:
- **Style**: Default
- **Base color**: Slate
- **CSS variables**: Yes
- **Tailwind config**: Yes
- **Import alias**: @/*

### 2. Install Required Components

Run these commands to add all required UI components:

```bash
# Layout & Structure
npx shadcn-ui@latest add card
npx shadcn-ui@latest add separator
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add scroll-area

# Inputs & Forms
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add label
npx shadcn-ui@latest add select
npx shadcn-ui@latest add checkbox
npx shadcn-ui@latest add switch
npx shadcn-ui@latest add slider
npx shadcn-ui@latest add textarea

# Display
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add avatar
npx shadcn-ui@latest add progress
npx shadcn-ui@latest add tooltip
npx shadcn-ui@latest add table

# Overlays & Dialogs
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add dropdown-menu
npx shadcn-ui@latest add popover
npx shadcn-ui@latest add alert-dialog
npx shadcn-ui@latest add sheet

# Feedback
npx shadcn-ui@latest add toast
npx shadcn-ui@latest add alert

# Navigation
npx shadcn-ui@latest add command

# Advanced
npx shadcn-ui@latest add calendar
npx shadcn-ui@latest add accordion
npx shadcn-ui@latest add toggle
npx shadcn-ui@latest add skeleton
```

Or install all at once:

```bash
npx shadcn-ui@latest add button card badge input label select separator avatar dropdown-menu dialog progress tabs toast tooltip table alert checkbox switch slider textarea scroll-area popover alert-dialog sheet command calendar accordion toggle skeleton
```

---

## 📦 Component Organization

```
components/
├── ui/                              # shadcn/ui base components
│   ├── button.tsx                   ✅ (example included)
│   ├── card.tsx                     ← Install with: npx shadcn-ui add card
│   ├── badge.tsx                    ← Install with: npx shadcn-ui add badge
│   ├── input.tsx                    ← Install with: npx shadcn-ui add input
│   ├── progress.tsx                 ← Install with: npx shadcn-ui add progress
│   ├── avatar.tsx                   ← Install with: npx shadcn-ui add avatar
│   ├── dropdown-menu.tsx            ← Install with: npx shadcn-ui add dropdown-menu
│   ├── dialog.tsx                   ← Install with: npx shadcn-ui add dialog
│   ├── toast.tsx                    ← Install with: npx shadcn-ui add toast
│   ├── tooltip.tsx                  ← Install with: npx shadcn-ui add tooltip
│   ├── table.tsx                    ← Install with: npx shadcn-ui add table
│   ├── tabs.tsx                     ← Install with: npx shadcn-ui add tabs
│   ├── select.tsx                   ← Install with: npx shadcn-ui add select
│   ├── slider.tsx                   ← Install with: npx shadcn-ui add slider
│   ├── separator.tsx                ← Install with: npx shadcn-ui add separator
│   ├── calendar.tsx                 ← Install with: npx shadcn-ui add calendar
│   └── ...                          (more as needed)
│
├── dashboard/                       # Dashboard page components
│   ├── PerformanceSnapshot.tsx      ← Create: metrics cards
│   ├── ContentStrategyTracker.tsx   ← Create: pillar progress bars
│   ├── WeeklySuggestions.tsx        ← Create: post suggestion cards
│   ├── WeeklyCalendar.tsx           ← Create: mini calendar widget
│   └── KnowledgeBaseStatus.tsx      ← Create: progress ring
│
├── radar/                           # Radar page components
│   ├── PostCard.tsx                 ← Create: post display card
│   ├── PostFilters.tsx              ← Create: filter controls
│   ├── ScoreVisualization.tsx       ← Create: score charts
│   ├── TopicDistribution.tsx        ← Create: topic breakdown
│   └── PostDetailModal.tsx          ← Create: post detail overlay
│
├── knowledge/                       # Knowledge Base page
│   ├── CreatorList.tsx              ← Create: creator table
│   ├── CreatorCard.tsx              ← Create: creator info card
│   ├── AddCreatorDialog.tsx         ← Create: add creator form
│   ├── CreatorStats.tsx             ← Create: per-creator analytics
│   └── UploadKnowledge.tsx          ← Create: file upload widget
│
├── calendar/                        # Calendar page
│   ├── CalendarGrid.tsx             ← Create: calendar grid view
│   ├── PostSlot.tsx                 ← Create: calendar time slot
│   ├── SchedulingPanel.tsx          ← Create: drag-drop panel
│   └── CalendarSettings.tsx         ← Create: settings dialog
│
├── logs/                            # Logs page
│   ├── RunsTable.tsx                ← Create: runs history table
│   ├── RunDetails.tsx               ← Create: detailed run view
│   ├── ErrorLog.tsx                 ← Create: error display
│   ├── ApiUsageChart.tsx            ← Create: cost tracking chart
│   └── RunStatusBadge.tsx           ← Create: status badge
│
└── shared/                          # Shared across app
    ├── Sidebar.tsx                  ✅ (in layout.tsx)
    ├── Header.tsx                   ✅ (in layout.tsx)
    ├── AssistantChat.tsx            ← Create: AI chat widget
    ├── LoadingStates.tsx            ← Create: skeleton loaders
    ├── EmptyStates.tsx              ← Create: empty illustrations
    ├── StatCard.tsx                 ← Create: reusable stat card
    ├── ChartWrapper.tsx             ← Create: chart container
    └── ExportButton.tsx             ← Create: export dropdown
```

---

## 🎯 Custom Components to Build

After installing shadcn/ui components, you'll need to create these custom components:

### 1. Dashboard Components

#### PerformanceSnapshot.tsx
```tsx
// Display 4 metric cards: creators, posts, engagement, generated
// Uses: Card, CardHeader, CardContent from shadcn
// Props: stats object
```

#### ContentStrategyTracker.tsx
```tsx
// Shows content pillar progress bars
// Uses: Progress from shadcn
// Props: strategy array with pillar data
```

#### WeeklySuggestions.tsx
```tsx
// Grid of post suggestion cards
// Uses: Card, Badge, Button from shadcn
// Props: suggestions array
```

#### KnowledgeBaseStatus.tsx
```tsx
// Circular progress ring + stats
// Custom SVG ring animation
// Props: completeness %, creators count, posts count
```

### 2. Radar Components

#### PostCard.tsx
```tsx
// Individual post display with scores
// Shows: text preview, creator, engagement, AI scores
// Uses: Card, Badge, Avatar, Tooltip
// Props: post object
```

#### PostFilters.tsx
```tsx
// Filter controls for posts
// Date range, score slider, creator select, category
// Uses: Select, Slider, DatePicker, Button
```

#### ScoreVisualization.tsx
```tsx
// Chart showing score distribution
// Uses: recharts (bar/line chart)
// Props: posts array
```

### 3. Knowledge Base Components

#### CreatorList.tsx
```tsx
// Table of all creators
// Sortable, filterable, paginated
// Uses: Table from shadcn
// Props: creators array
```

#### AddCreatorDialog.tsx
```tsx
// Form to add new creator
// LinkedIn URL input + validation
// Uses: Dialog, Input, Button, Label
```

### 4. Calendar Components

#### CalendarGrid.tsx
```tsx
// Weekly/monthly calendar view
// Drag-and-drop slots
// Uses: Calendar from shadcn + react-dnd
// Props: posts array, onSchedule callback
```

#### SchedulingPanel.tsx
```tsx
// Sidebar with unscheduled posts
// Drag to calendar to schedule
// Uses: Card, ScrollArea, Badge
```

### 5. Logs Components

#### RunsTable.tsx
```tsx
// Table of automation runs
// Status, date, stats, actions
// Uses: Table from shadcn
// Props: runs array
```

#### ApiUsageChart.tsx
```tsx
// Line/area chart of API costs over time
// Uses: recharts
// Props: usage data array
```

---

## 🎨 Styling Guide

### Color Usage

```tsx
// Status colors
<Badge className="badge-success">Completed</Badge>
<Badge className="badge-warning">Partial</Badge>
<Badge className="badge-error">Failed</Badge>
<Badge className="badge-info">Running</Badge>

// Gradient text (Scripe style)
<h1 className="gradient-text">LinkedIn Radar</h1>

// Gradient button
<Button className="bg-gradient-scripe">
  Trigger Automation
</Button>

// Card hover effect
<Card className="card-hover">
  {/* content */}
</Card>

// Glass effect
<div className="glass rounded-lg p-4">
  {/* content */}
</div>
```

### Animations

```tsx
// Fade in
<div className="animate-fade-in">...</div>

// Slide in
<div className="animate-slide-in">...</div>

// Pulse (for loading)
<div className="animate-pulse-slow">...</div>

// Spin (for loaders)
<RefreshCw className="animate-spin" />
```

---

## 📊 Chart Components

### Install Recharts

```bash
npm install recharts
```

### Example Usage

```tsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

export function EngagementChart({ data }: { data: any[] }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
        <XAxis dataKey="date" stroke="hsl(var(--muted-foreground))" />
        <YAxis stroke="hsl(var(--muted-foreground))" />
        <Tooltip
          contentStyle={{
            backgroundColor: 'hsl(var(--card))',
            border: '1px solid hsl(var(--border))',
          }}
        />
        <Line
          type="monotone"
          dataKey="engagement"
          stroke="hsl(var(--primary))"
          strokeWidth={2}
        />
      </LineChart>
    </ResponsiveContainer>
  )
}
```

---

## 🔄 Real-time Updates

### Using Supabase Realtime

```tsx
'use client'

import { useEffect } from 'react'
import { createBrowserClient } from '@/lib/supabase'
import { useQueryClient } from '@tanstack/react-query'

export function useRealtimeRuns() {
  const queryClient = useQueryClient()
  const supabase = createBrowserClient()

  useEffect(() => {
    const channel = supabase
      .channel('automation_runs')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'automation_runs',
        },
        (payload) => {
          // Invalidate runs query to refetch
          queryClient.invalidateQueries({ queryKey: ['runs'] })
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [supabase, queryClient])
}
```

Use in component:
```tsx
function LogsPage() {
  useRealtimeRuns() // Subscribe to updates

  const { data: runs } = useQuery({
    queryKey: ['runs'],
    queryFn: fetchRuns,
  })

  return <RunsTable runs={runs} />
}
```

---

## 🧪 Testing Components

```tsx
// Example: Test PostCard component
import { render, screen } from '@testing-library/react'
import { PostCard } from '@/components/radar/PostCard'

test('renders post card with title', () => {
  const mockPost = {
    id: '1',
    title: 'Test Post',
    score: 24,
    creator: 'John Doe',
  }

  render(<PostCard post={mockPost} />)

  expect(screen.getByText('Test Post')).toBeInTheDocument()
  expect(screen.getByText('Score: 24')).toBeInTheDocument()
})
```

---

## 📚 Resources

- [shadcn/ui Docs](https://ui.shadcn.com/)
- [Radix UI Primitives](https://www.radix-ui.com/primitives)
- [Recharts Docs](https://recharts.org/)
- [TanStack Query Docs](https://tanstack.com/query/latest)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)

---

## 🎯 Next Steps

1. Install all shadcn/ui components: `npx shadcn-ui@latest add [component]`
2. Create custom dashboard components in `components/dashboard/`
3. Create radar page components in `components/radar/`
4. Create knowledge base components in `components/knowledge/`
5. Create calendar components in `components/calendar/`
6. Create logs components in `components/logs/`
7. Add real-time subscriptions with Supabase
8. Implement drag-and-drop with react-dnd
9. Add charts with Recharts
10. Test components with React Testing Library

---

**Pro Tip:** Start with the Dashboard page components first, then move to Radar, then Knowledge Base, Calendar, and Logs. Build incrementally!
