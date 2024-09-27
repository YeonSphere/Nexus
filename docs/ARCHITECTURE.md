# Nexus Browser Architecture

## Overview

Nexus Browser is built using Electron and TypeScript, providing a robust and extensible architecture for a modern web browser.

## Main Components

1. Main Process (`src/main/main.ts`)
   - Handles the creation of browser windows and IPC communication

2. Renderer Process
   - BrowserUI (`src/renderer/components/BrowserUI.tsx`)
   - TabManager (`src/renderer/components/TabManager.tsx`)
   - Navigation (`src/renderer/components/Navigation.tsx`)

3. Preload Script (`src/preload/preload.ts`)
   - Provides a secure bridge between renderer and main processes

4. Ad Blocker (`src/utils/adBlocker.ts`)
   - Implements ad blocking functionality

## Data Flow

[Include a diagram or description of how data flows between components]

## Extension System

[Describe how the extension system works]

## Future Improvements

[List potential areas for improvement or planned features]
