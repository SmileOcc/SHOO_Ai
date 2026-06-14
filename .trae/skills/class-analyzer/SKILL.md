---
name: "class-analyzer"
description: "Analyzes Dart/Flutter classes with architecture diagrams, comparison tables, and best practices. Invoke when user asks for class analysis or wants to understand a class's design."
---

# Class Analyzer Skill

This skill provides comprehensive analysis of Dart/Flutter classes, focusing on design patterns, technical comparisons, and best practices.

## When to Invoke

**Invoke this skill IMMEDIATELY when:**
- User asks to analyze a class (e.g., "analyze this class", "explain this class")
- User wants to understand a class's design rationale
- User requests comparison of different implementation approaches
- User asks for architecture explanation of a class
- User mentions "class analysis", "类分析", "详细说明"

## Analysis Structure

### 1. Class Overview
- Core responsibilities and purpose
- Problem it solves
- Position in the overall architecture

### 2. Code Segment Analysis

For each key code segment, provide:

**Code Segment: [code snippet]**
- **Functionality**: What does this code do?
- **Implementation Rationale**: Design thinking and technical considerations
- **Technical Comparison Table**:
  | Approach | Pros | Cons | Use Cases |
  |----------|------|------|-----------|
  | Current approach | ... | ... | ... |
  | Alternative A | ... | ... | ... |
  | Alternative B | ... | ... | ... |
- **Advantages Summary**: Why this approach was chosen?

### 3. Architecture Design
- Draw architecture diagram (using ASCII art or Mermaid)
- Explain component interactions
- Data flow and control flow

### 4. Comparison with Other Approaches

Compare with at least 3 similar technical approaches:

| Feature | Current Approach | Approach A | Approach B |
|---------|-----------------|------------|------------|
| Feature 1 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Feature 2 | ... | ... | ... |
| **Overall Rating** | ... | ... | ... |

**Advantages Summary**:
- ✅ Advantage 1
- ✅ Advantage 2
- ✅ Advantage 3

### 5. Best Practices
- Suitable scenarios
- Unsuitable scenarios
- Extension suggestions
- Important considerations

### 6. Code Examples
Provide usage examples and best practice code

## Analysis Guidelines

### Focus Areas
1. **Technical Rationale**: Why was this approach chosen?
2. **Comparison Advantages**: What makes this better than alternatives?
3. **Best Practices**: How to use it effectively in real projects?

### Output Requirements
- Use comparison tables for technical approaches
- Include architecture diagrams
- Provide star ratings (⭐) for quick comparison
- Summarize advantages with ✅ checkmarks
- Use clear section headers

### Language Requirements
- Match the user's language (Chinese or English)
- For code comments, follow the same language rule
- Maintain consistency throughout the analysis

## Example Usage

**User Request**: "请详细分析这个类的设计思路"

**Skill Response**:
