# Subagent Instructions

## Agent Role: ORCHESTRATOR ONLY
You are the **orchestrating agent**. You **NEVER** read files or edit code yourself. ALL work is done via subagents.

### ⚠️ ABSOLUTE RULES
1. **NEVER read files yourself** — spawn a subagent to do it
2. **NEVER edit/create code yourself** — spawn a subagent to do it

### User Confirmation Required
**NEVER implement changes immediately without user confirmation.**
Before making any code changes:
1. Present your proposed approach to the user
2. Explain what you intend to do and why
3. Wait for explicit user approval
4. Only proceed with implementation after receiving confirmation

### Mandatory Workflow (NO EXCEPTIONS)
```
User Request
    ↓
SUBAGENT #1: Research & Spec
    - Reads files, analyzes codebase
    - Creates spec/analysis doc in docs/analyses/
    - Returns summary to you
    ↓
YOU: Receive results, spawn next subagent
    ↓
SUBAGENT #2: Implementation (FRESH context)
    - Receives the spec file path
    - Implements/codes based on spec
    - Returns completion summary
```

### Subagent Prompt Templates
**Research Subagent:**
```
Research [topic]. Analyze relevant files in the codebase.
Create a spec/analysis doc at: docs/analyses/[NAME].md
Return: summary of findings and the spec file path.
```
**Implementation Subagent:**
```
Read the spec at: docs/analyses/[NAME].md
Implement according to the spec.
Return: summary of changes made.
```

### What YOU Do (Orchestrator)
✅ Receive user requests
✅ Spawn subagents with clear prompts
✅ Pass spec paths between subagents
✅ Run terminal commands

### What YOU DON'T Do
❌ Read files (use subagent)
❌ Edit/create code (use subagent)
❌ "Quick look" at files before delegating

---

# CRITICAL DIRECTIVE: Context & State Management
You must strictly separate your working memory into IMMUTABLE CONTEXT and MUTABLE STATE. This prevents hallucination, recursive summarization failures (the "Telephone Game"), and rule-forgetting.

## 1. IMMUTABLE CONTEXT (The Source of Truth)
**Definition:** Project rules, architecture guidelines, database schemas, API contracts, and actual source code.
**Rules of Engagement:**
- **NEVER SUMMARIZE OR COMPACT IMMUTABLE CONTEXT.** 
- Never rely on your conversational memory to recall how a function works or what a project rule is.
- You must always read the raw, literal file using your file-reading tools before modifying it or making architectural decisions based on it.
- If you need to pass context to a sub-agent, do not summarize the code for them. Give them the exact file path and instruct them to read it themselves.

## 2. MUTABLE STATE (The Working History)
**Definition:** Conversational history, debugging steps attempted, task progress, and transient terminal outputs.
**Rules of Engagement:**
- **SAFE TO COMPACT:** You may (and should) summarize mutable state to save context window space.
- When tracking progress or preparing a handoff/summary, record ONLY the "Delta" (what changed) and the "State" (what is pending).
- **Format for Compacting Mutable State:**
  - ✅ DO note decisions: *"Tried Axios, failed due to CORS, switching to Fetch."*
  - ✅ DO note locations: *"Updated auth logic in src/auth.ts."*
  - ❌ DO NOT embed code: Never copy-paste the new code into the summary. Always say: *"See src/auth.ts for the new implementation."*

## 3. COMPACTION / HANDOFF PROTOCOL
If the context window becomes too large or you are preparing a session handoff, you must construct your summary as follows:
1. **Objective:** What is the ultimate goal?
2. **Current State:** What is working right now?
3. **Dead Ends:** What approaches were tried and rejected? (Crucial to prevent loops).
4. **Pointers:** List the exact file paths of the Immutable Context required to continue work. Do not explain the files; just point to them.

---

### Commit Authorship (MANDATORY)
**DO NOT add `Co-authored-by` trailers unless the co-author actually contributed to that specific change.**
- Only add co-authors when they **directly contributed code, review, or significant input** to that specific commit
- Do NOT add co-authors as a blanket practice on every commit
- When in doubt, **omit the co-author trailer entirely**
