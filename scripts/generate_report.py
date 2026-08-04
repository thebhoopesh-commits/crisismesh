from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, ListFlowable, ListItem, KeepTogether
from reportlab.platypus.flowables import HRFlowable
import os
from datetime import datetime

# Define output path
output_dir = r"D:\crisismesh\crisismesh\docs"
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "CrisisMesh_Medical_Chatbot_Architecture_Report.pdf")

# Custom styles
styles = getSampleStyleSheet()

title_style = ParagraphStyle(
    'CustomTitle',
    parent=styles['Title'],
    fontSize=24,
    leading=28,
    spaceAfter=6,
    textColor=HexColor('#1a3c5e'),
    alignment=TA_CENTER,
)

subtitle_style = ParagraphStyle(
    'CustomSubtitle',
    parent=styles['Normal'],
    fontSize=13,
    leading=16,
    spaceAfter=20,
    textColor=HexColor('#4a6fa5'),
    alignment=TA_CENTER,
)

section_style = ParagraphStyle(
    'SectionHeader',
    parent=styles['Heading1'],
    fontSize=16,
    leading=20,
    spaceBefore=18,
    spaceAfter=10,
    textColor=HexColor('#1a3c5e'),
    borderWidth=0,
    borderPadding=0,
)

subsection_style = ParagraphStyle(
    'SubSectionHeader',
    parent=styles['Heading2'],
    fontSize=13,
    leading=16,
    spaceBefore=12,
    spaceAfter=6,
    textColor=HexColor('#2d5a8a'),
)

body_style = ParagraphStyle(
    'CustomBody',
    parent=styles['Normal'],
    fontSize=10,
    leading=14,
    spaceAfter=6,
    alignment=TA_JUSTIFY,
    textColor=HexColor('#2c3e50'),
)

bullet_style = ParagraphStyle(
    'CustomBullet',
    parent=styles['Normal'],
    fontSize=10,
    leading=14,
    spaceAfter=4,
    leftIndent=20,
    bulletIndent=8,
    textColor=HexColor('#2c3e50'),
)

code_style = ParagraphStyle(
    'CodeBlock',
    parent=styles['Normal'],
    fontSize=9,
    leading=12,
    spaceAfter=8,
    leftIndent=24,
    fontName='Courier',
    backColor=HexColor('#f4f4f4'),
    borderWidth=1,
    borderColor=HexColor('#ddd'),
    borderPadding=6,
    textColor=HexColor('#333'),
)

table_header_style = ParagraphStyle(
    'TableHeader',
    parent=styles['Normal'],
    fontSize=9,
    leading=12,
    textColor=HexColor('#ffffff'),
    fontName='Helvetica-Bold',
)

table_cell_style = ParagraphStyle(
    'TableCell',
    parent=styles['Normal'],
    fontSize=9,
    leading=12,
    textColor=HexColor('#2c3e50'),
)

# Build document
doc = SimpleDocTemplate(
    output_path,
    pagesize=A4,
    topMargin=0.8*inch,
    bottomMargin=0.8*inch,
    leftMargin=0.9*inch,
    rightMargin=0.9*inch,
)

story = []

# ============================================================
# TITLE PAGE
# ============================================================
story.append(Spacer(1, 1.5*inch))
story.append(Paragraph("CrisisMesh", title_style))
story.append(Spacer(1, 0.2*inch))
story.append(Paragraph("Medical Chatbot Architecture & Communication Standards Report", subtitle_style))
story.append(Spacer(1, 0.5*inch))
story.append(HRFlowable(width="80%", thickness=2, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.5*inch))

meta_data = [
    ["Project:", "CrisisMesh — Offline Emergency Medical Triage"],
    ["Component:", "Triage Engine & Communication Layer"],
    ["Prepared By:", "CrisisMesh Lead Developer (AI Agent)"],
    ["Date:", datetime.now().strftime("%B %d, %Y")],
    ["Version:", "1.0 — Technical Specification"],
    ["Classification:", "Internal — Architecture Reference"],
]

meta_table = Table(meta_data, colWidths=[1.5*inch, 4.5*inch])
meta_table.setStyle(TableStyle([
    ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 10),
    ('TEXTCOLOR', (0, 0), (0, -1), HexColor('#1a3c5e')),
    ('TEXTCOLOR', (1, 0), (1, -1), HexColor('#2c3e50')),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ('LINEBELOW', (0, 0), (-1, -2), 0.5, HexColor('#e0e0e0')),
]))
story.append(meta_table)

story.append(PageBreak())

# ============================================================
# TABLE OF CONTENTS (Manual)
# ============================================================
story.append(Paragraph("Table of Contents", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.2*inch))

toc_items = [
    ("1.", "Executive Summary"),
    ("2.", "Medical Chatbot Communication Standards"),
    ("  2.1", "Core Principles: Empathetic Clarity"),
    ("  2.2", "Tone & Style Guidelines"),
    ("  2.3", "Safety Guardrails & Emergency Protocols"),
    ("  2.4", "Quick Reference: Do's and Don'ts"),
    ("3.", "Triage Engine Analysis (triage_engine.dart)"),
    ("  3.1", "Current Implementation Review"),
    ("  3.2", "Critical Gaps Identified"),
    ("  3.3", "Recommended Improvements"),
    ("4.", "Architectural Decision: Pipeline vs. Multi-Agent"),
    ("  4.1", "Comparative Analysis"),
    ("  4.2", "Recommended: Modular Pipeline Architecture"),
    ("  4.3", "Where Agents Belong: Background Workers"),
    ("5.", "Implementation Roadmap"),
    ("  5.1", "Phase 1: Data Scrubbing & PHI Protection"),
    ("  5.2", "Phase 2: Structured Output Pipeline"),
    ("  5.3", "Phase 3: Hardened Emergency Overrides"),
    ("6.", "Appendix: Industry Standards Compliance"),
]

for num, title in toc_items:
    indent = 30 if num.startswith("  ") else 0
    style = ParagraphStyle('TOCItem', parent=body_style, leftIndent=indent, spaceAfter=3, fontSize=10)
    story.append(Paragraph(f"{num.strip()} &nbsp;&nbsp; {title}", style))

story.append(PageBreak())

# ============================================================
# 1. EXECUTIVE SUMMARY
# ============================================================
story.append(Paragraph("1. Executive Summary", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.1*inch))

story.append(Paragraph(
    "This document consolidates the architectural research, code analysis, and design decisions for the CrisisMesh "
    "medical chatbot component. The system is designed to operate <b>entirely offline</b> during disaster scenarios, "
    "providing immediate, life-saving triage guidance via a local LLM (Gemma via LiteRT) on mobile devices.",
    body_style
))
story.append(Paragraph(
    "Our research establishes that the chatbot must adopt an <b>Empathetic Clarity</b> communication style — validating "
    "user emotion first, then delivering concise, authoritative, step-by-step medical instructions. Critically, the "
    "system must implement <b>deterministic emergency overrides</b> that bypass the LLM entirely when life-threatening "
    "conditions are detected, ensuring zero-latency, zero-failure responses for scenarios like cardiac arrest, severe "
    "bleeding, or airway obstruction.",
    body_style
))
story.append(Paragraph(
    "The current <font face='Courier'>triage_engine.dart</font> provides a functional foundation but lacks PHI scrubbing, "
    "structured output enforcement, and hardcoded emergency bypass logic. This report details a three-phase "
    "implementation roadmap to harden the component to production-grade medical device standards, aligned with HIPAA, "
    "ISO 27001, and clinical safety best practices.",
    body_style
))

story.append(PageBreak())

# ============================================================
# 2. MEDICAL CHATBOT COMMUNICATION STANDARDS
# ============================================================
story.append(Paragraph("2. Medical Chatbot Communication Standards", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.1*inch))

# 2.1 Core Principles
story.append(Paragraph("2.1 Core Principles: Empathetic Clarity", subsection_style))
story.append(Paragraph(
    "The primary objective of the CrisisMesh chatbot is to establish <b>Trust</b> and reduce user <b>Anxiety</b> "
    "while maintaining professional medical boundaries. The recommended style — <b>Empathetic Clarity</b> — blends "
    "validating warmth with clinical precision.",
    body_style
))

principles = [
    ("Acknowledge Emotion First", "Never jump straight into facts. Start by validating the user's emotional state. "
     "Example: <i>\"It sounds like you are feeling quite worried about these symptoms, and that is completely understandable.\"</i>"),
    ("Use Qualifying Language", "Integrate disclaimer reminders naturally into the consultation flow, not as repetitive boilerplate. "
     "Example: <i>\"As always, remember that I am an AI and this conversation does not replace a doctor's visit.\"</i>"),
    ("Plain Language Mandate", "Eliminate all medical jargon unless the user demonstrates familiarity. If a term is necessary, "
     "define it immediately inline. Example: <i>\"passing excessive amounts of urine (polyuria)\"</i>"),
    ("Chunk Information", "Break complex guidance into bite-sized pieces using bullet points, numbered lists, or sequential steps. "
     "Never deliver a wall of text."),
    ("Clear Next Steps", "Every interaction must conclude with a single, unambiguous call to action (e.g., booking, symptom check, "
     "medication review)."),
    ("Professional Distance", "Helpful and caring without being a friend. Avoid overuse of emojis or casual language. Tone should "
     "mirror a trusted, knowledgeable medic."),
    ("Never Diagnose Definitively", "The chatbot must never offer a final diagnosis or cure. It provides triage guidance and "
     "immediate action steps only."),
    ("Source Attribution", "Always imply the basis of information conceptually: <i>\"According to general guidelines for...\"</i> "
     "or <i>\"Most specialists advise that...\"</i>"),
]

for title, desc in principles:
    story.append(Paragraph(f"<b>{title}:</b> {desc}", bullet_style))

# 2.2 Tone & Style Guidelines
story.append(Paragraph("2.2 Tone & Style Guidelines", subsection_style))

tone_data = [
    [Paragraph("<b>Dimension</b>", table_header_style),
     Paragraph("<b>Goal</b>", table_header_style),
     Paragraph("<b>Do This ✅</b>", table_header_style),
     Paragraph("<b>Don't Do This ❌</b>", table_header_style)],
    [Paragraph("Tone", table_cell_style),
     Paragraph("Empathy", table_cell_style),
     Paragraph("Validate feelings first: <i>\"I hear that this is stressful.\"</i>", table_cell_style),
     Paragraph("Sound cold or dismissive: <i>\"Just take the pill and wait.\"</i>", table_cell_style)],
    [Paragraph("Content", table_cell_style),
     Paragraph("Clarity", table_cell_style),
     Paragraph("Short lists, plain language, 1–2 key takeaways", table_cell_style),
     Paragraph("Dump paragraphs; use undefined acronyms", table_cell_style)],
    [Paragraph("Safety", table_cell_style),
     Paragraph("Guardrails", table_cell_style),
     Paragraph("Clear next steps & emergency hotlines", table_cell_style),
     Paragraph("Overpromise or attempt final diagnosis", table_cell_style)],
    [Paragraph("Structure", table_cell_style),
     Paragraph("Actionability", table_cell_style),
     Paragraph("Step-by-step field-expedient instructions", table_cell_style),
     Paragraph("Theoretical or hospital-dependent advice", table_cell_style)],
]

tone_table = Table(tone_data, colWidths=[0.7*inch, 0.7*inch, 2.3*inch, 2.3*inch])
tone_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), HexColor('#1a3c5e')),
    ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#ffffff')),
    ('BACKGROUND', (0, 1), (-1, -1), HexColor('#f8f9fa')),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [HexColor('#f8f9fa'), HexColor('#ffffff')]),
    ('GRID', (0, 0), (-1, -1), 0.5, HexColor('#ddd')),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
]))
story.append(tone_table)

# 2.3 Safety Guardrails
story.append(Paragraph("2.3 Safety Guardrails & Emergency Protocols", subsection_style))
story.append(Paragraph(
    "The following guardrails are <b>non-negotiable</b> and must be implemented at the code level (not relying on "
    "LLM compliance):",
    body_style
))

guardrails = [
    "<b>Hardcoded Emergency Keyword Intercept:</b> Before any LLM call, scan input for life-threatening patterns "
    "(\"can't breathe\", \"massive bleeding\", \"chest pain\", \"unconscious\", \"severe burns\", \"cardiac arrest\"). "
    "If matched, immediately return a hardcoded CRITICAL EMERGENCY block with local emergency numbers.",
    "<b>LLM Bypass on Critical Match:</b> The emergency response must not touch the model. It is a static, "
    "pre-validated string to guarantee zero latency and zero hallucination risk.",
    "<b>Structured Disclaimer Injection:</b> Every non-emergency response must include a contextually appropriate "
    "disclaimer (e.g., \"This is triage guidance, not a diagnosis. Seek professional care when available.\").",
    "<b>Input Sanitization:</b> Strip PII (names, addresses, DOB, phone numbers) from user input before it enters "
    "the prompt context to maintain PHI compliance.",
    "<b>Output Schema Enforcement:</b> LLM responses must conform to a strict JSON schema (severity, actions[], "
    "next_question, disclaimer) to prevent UI parsing failures.",
]

for g in guardrails:
    story.append(Paragraph(g, bullet_style))

# 2.4 Quick Reference
story.append(Paragraph("2.4 Quick Reference: Do's and Don'ts", subsection_style))

quick_data = [
    [Paragraph("<b>✅ DO</b>", table_header_style), Paragraph("<b>❌ DON'T</b>", table_header_style)],
    [Paragraph("Acknowledge emotion before educating", table_cell_style), Paragraph("Jump straight to medical facts", table_cell_style)],
    [Paragraph("Use plain language + define terms inline", table_cell_style), Paragraph("Use jargon (myocardial infarction, polyuria)", table_cell_style)],
    [Paragraph("Provide numbered, step-by-step actions", table_cell_style), Paragraph("Deliver walls of unstructured text", table_cell_style)],
    [Paragraph("End with one clear next step", table_cell_style), Paragraph("Leave user without direction", table_cell_style)],
    [Paragraph("Implement hardcoded emergency bypass", table_cell_style), Paragraph("Rely on LLM to detect emergencies", table_cell_style)],
    [Paragraph("Scrub PII before prompt construction", table_cell_style), Paragraph("Pass raw user input to LLM", table_cell_style)],
    [Paragraph("Enforce JSON output schema", table_cell_style), Paragraph("Accept free-form text from model", table_cell_style)],
    [Paragraph("Maintain professional medic tone", table_cell_style), Paragraph("Use excessive emojis or casual slang", table_cell_style)],
]

quick_table = Table(quick_data, colWidths=[3*inch, 3*inch])
quick_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), HexColor('#1a3c5e')),
    ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#ffffff')),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [HexColor('#f8f9fa'), HexColor('#ffffff')]),
    ('GRID', (0, 0), (-1, -1), 0.5, HexColor('#ddd')),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
]))
story.append(quick_table)

story.append(PageBreak())

# ============================================================
# 3. TRIAGE ENGINE ANALYSIS
# ============================================================
story.append(Paragraph("3. Triage Engine Analysis (triage_engine.dart)", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.1*inch))

# 3.1 Current Implementation
story.append(Paragraph("3.1 Current Implementation Review", subsection_style))
story.append(Paragraph(
    "The current <font face='Courier'>triage_engine.dart</font> (located at <font face='Courier'>lib/chat/triage_engine.dart</font>) "
    "implements a <font face='Courier'>TriageEngine</font> abstract class with a single concrete implementation: "
    "<font face='Courier'>LiteRTGemmaEngine</font>. Key characteristics:",
    body_style
))

current_items = [
    "<b>Offline-First:</b> Uses Flutter <font face='Courier'>MethodChannel</font> to communicate with native "
    "Android/iOS code running Gemma via LiteRT — fully offline capable.",
    "<b>Stateless Request/Response:</b> The <font face='Courier'>respond(String input)</font> method accepts a raw "
    "string and returns a tuple of <font face='Courier'>(String reply, List<String> suggestions)</font>.",
    "<b>Hardcoded System Prompt:</b> The prompt template (lines 31–42) defines the persona, rules, and emergency "
    "detection instructions entirely within the Dart string.",
    "<b>Basic Error Handling:</b> A single <font face='Courier'>try/catch</font> wraps the native call, returning "
    "a generic error message on failure.",
    "<b>Static Suggestions:</b> Returns hardcoded suggestion chips: <font face='Courier'>['Need more info', 'Thanks']</font>.",
]

for item in current_items:
    story.append(Paragraph(item, bullet_style))

# 3.2 Critical Gaps
story.append(Paragraph("3.2 Critical Gaps Identified", subsection_style))
story.append(Paragraph(
    "The following gaps were identified through code review and measured against medical device software standards "
    "(IEC 62304, FDA SaMD guidance) and healthcare data regulations (HIPAA, GDPR):",
    body_style
))

gaps = [
    ("🔴 CRITICAL: No Deterministic Emergency Bypass",
     "Emergency detection relies entirely on the LLM interpreting the prompt rule #3. "
     "Subtle phrasing, typos, or model quantization artifacts can cause the model to miss a life-threatening condition. "
     "There is zero guarantee of detection."),
    ("🔴 CRITICAL: No PHI Scrubbing / Input Sanitization",
     "Raw user input is interpolated directly into the prompt. Names, addresses, phone numbers, and other PII are "
     "sent to the model context, violating data minimization principles and potentially exposing PHI in logs."),
    ("🟠 HIGH: Unstructured Output / No Schema Enforcement",
     "The model returns free-form text. The UI cannot reliably parse severity, action steps, or follow-up questions. "
     "Any change in model verbosity breaks downstream rendering."),
    ("🟠 HIGH: Generic Error Handling",
     "All failures (model load, generation timeout, native crash) return the same user-facing message. No graceful "
     "degradation to offline-first-aid-cards or cached guidance."),
    ("🟡 MEDIUM: Stateless Design",
     "No conversation history or triage state is passed. The model cannot reference prior steps (e.g., "
     "\"You already applied pressure for 5 minutes\"), leading to contradictory or repetitive advice."),
    ("🟡 MEDIUM: Static Suggestion Chips",
     "Suggestions are hardcoded and context-unaware. They should reflect the triage state (e.g., "
     "\"Check pulse\", \"Prepare for CPR\", \"Monitor breathing\")."),
]

for title, desc in gaps:
    story.append(Paragraph(f"<b>{title}</b>", bullet_style))
    story.append(Paragraph(desc, ParagraphStyle('GapDesc', parent=body_style, leftIndent=28, spaceAfter=8)))

# 3.3 Recommended Improvements
story.append(Paragraph("3.3 Recommended Improvements", subsection_style))
story.append(Paragraph(
    "Three priority improvements, ordered by risk reduction impact:",
    body_style
))

improvements = [
    ("1. Hardcoded Emergency Override (CRITICAL_OVERRIDE)",
     "Add a synchronous Dart function <font face='Courier'>checkCriticalEmergency(input)</font> that runs a "
     "regex/keyword match against a curated list of life-threatening patterns. If matched, return a pre-validated "
     "emergency response object immediately — <b>bypassing the LLM entirely</b>."),
    ("2. Input Scrubbing Layer (scrubAndPrepareInput)",
     "Insert a preprocessing step that removes PII using regex patterns (names, phones, emails, addresses, DOBs) "
     "while preserving medical terminology. Returns a sanitized string for prompt construction."),
    ("3. Structured Output Schema",
     "Redesign the prompt to require JSON output conforming to a strict schema. Update the return type from "
     "<font face='Courier'>(String, List<String>)</font> to a typed <font face='Courier'>TriageResponse</font> "
     "class with fields: <font face='Courier'>severity, actions[], nextQuestion, disclaimer, suggestions[]</font>."),
]

for title, desc in improvements:
    story.append(Paragraph(f"<b>{title}</b>", bullet_style))
    story.append(Paragraph(desc, ParagraphStyle('ImpDesc', parent=body_style, leftIndent=28, spaceAfter=10)))

story.append(PageBreak())

# ============================================================
# 4. ARCHITECTURAL DECISION
# ============================================================
story.append(Paragraph("4. Architectural Decision: Pipeline vs. Multi-Agent", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.1*inch))

# 4.1 Comparative Analysis
story.append(Paragraph("4.1 Comparative Analysis", subsection_style))
story.append(Paragraph(
    "We evaluated whether the core triage loop should use a Multi-Agent System (MAS) — where independent agents "
    "communicate asynchronously — versus a Modular Pipeline Architecture. The comparison below reflects CrisisMesh's "
    "constraints: offline, mobile, life-critical, low-latency.",
    body_style
))

arch_data = [
    [Paragraph("<b>Feature</b>", table_header_style),
     Paragraph("<b>Multi-Agent System</b>", table_header_style),
     Paragraph("<b>Modular Pipeline (Recommended)</b>", table_header_style)],
    [Paragraph("Execution Model", table_cell_style),
     Paragraph("Async, concurrent, message passing between agents", table_cell_style),
     Paragraph("Synchronous, sequential function calls", table_cell_style)],
    [Paragraph("Latency", table_cell_style),
     Paragraph("HIGH RISK — Unpredictable inter-agent delays", table_cell_style),
     Paragraph("LOW, PREDICTABLE — Deterministic step timing", table_cell_style)],
    [Paragraph("Failure Surface", table_cell_style),
     Paragraph("Complex — comms failures, agent crashes, deadlocks", table_cell_style),
     Paragraph("Simple — single function failure, targeted fallback", table_cell_style)],
    [Paragraph("Debugging", table_cell_style),
     Paragraph("Difficult — distributed state, race conditions", table_cell_style),
     Paragraph("Straightforward — stack trace points to exact line", table_cell_style)],
    [Paragraph("State Management", table_cell_style),
     Paragraph("Complex — shared memory, consensus protocols", table_cell_style),
     Paragraph("Explicit — passed as function arguments", table_cell_style)],
    [Paragraph("Best Fit", table_cell_style),
     Paragraph("Background: research, reporting, synthesis", table_cell_style),
     Paragraph("Core path: triage, vitals, immediate action", table_cell_style)],
]

arch_table = Table(arch_data, colWidths=[1.2*inch, 2.4*inch, 2.4*inch])
arch_table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), HexColor('#1a3c5e')),
    ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#ffffff')),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [HexColor('#f8f9fa'), HexColor('#ffffff')]),
    ('GRID', (0, 0), (-1, -1), 0.5, HexColor('#ddd')),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ('TOPPADDING', (0, 0), (-1, -1), 6),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('RIGHTPADDING', (0, 0), (-1, -1), 6),
]))
story.append(arch_table)

# 4.2 Recommended Architecture
story.append(Paragraph("4.2 Recommended: Modular Pipeline Architecture", subsection_style))
story.append(Paragraph(
    "The core <font face='Courier'>respond()</font> method should execute a strict, sequential pipeline. Each stage "
    "is a pure Dart function with a single responsibility, making the entire flow testable, auditable, and "
    "deterministic.",
    body_style
))

pipeline_steps = [
    ("1. <font face='Courier'>scrubAndPrepareInput(rawInput)</font>",
     "Regex-based PII removal, input normalization, length limits. Returns <font face='Courier'>SanitizedInput</font>."),
    ("2. <font face='Courier'>checkCriticalEmergency(sanitizedInput)</font>",
     "Deterministic keyword/regex match against curated emergency patterns. Returns <font face='Courier'>EmergencyResponse?</font> (null if no match)."),
    ("3. <font face='Courier'>buildPrompt(sanitizedInput, history, triageState)</font>",
     "Constructs the structured prompt including conversation history, current triage checkpoint, and JSON output schema instructions."),
    ("4. <font face='Courier'>invokeModel(prompt)</font>",
     "Calls the native MethodChannel. Handles timeouts, model load failures, and native exceptions with typed errors."),
    ("5. <font face='Courier'>parseAndValidateResponse(rawOutput)</font>",
     "Parses JSON, validates against schema, applies guardrails (no diagnoses, appropriate disclaimer). Returns <font face='Courier'>TriageResponse</font>."),
    ("6. <font face='Courier'>generateSuggestions(triageResponse, triageState)</font>",
     "Context-aware suggestion chips based on current severity and triage phase."),
]

for title, desc in pipeline_steps:
    story.append(Paragraph(f"<b>{title}</b>", bullet_style))
    story.append(Paragraph(desc, ParagraphStyle('PipeDesc', parent=body_style, leftIndent=28, spaceAfter=8)))

# 4.3 Where Agents Belong
story.append(Paragraph("4.3 Where Agents Belong: Background Workers", subsection_style))
story.append(Paragraph(
    "Multi-agent patterns have a place in CrisisMesh — but <b>outside the real-time triage loop</b>. Recommended uses:",
    body_style
))

agent_uses = [
    "<b>Research Synthesis Agent:</b> Triggered when user asks \"What are long-term risks?\" — runs in background, "
    "queries local medical knowledge base, returns structured summary.",
    "<b>Incident Report Generator:</b> On incident closure, a background worker compiles chat transcript, triage "
    "decisions, and timestamps into a standardized medical report (PDF/JSON) for handoff to professionals.",
    "<b>Model Evaluation Agent:</b> Periodically (offline) runs benchmark prompts against the local Gemma model to "
    "detect quantization drift or regression in medical accuracy.",
    "<b>Knowledge Base Curator:</b> When new clinical guidelines are released (via periodic sync), an agent parses "
    "and updates the local RAG index.",
]

for use in agent_uses:
    story.append(Paragraph(use, bullet_style))

story.append(PageBreak())

# ============================================================
# 5. IMPLEMENTATION ROADMAP
# ============================================================
story.append(Paragraph("5. Implementation Roadmap", section_style))
story.append(HRFlowable(width="100%", thickness=1, color=HexColor('#1a3c5e')))
story.append(Spacer(1, 0.1*inch))

# Phase 1
story.append(Paragraph("5.1 Phase 1: Data Scrubbing & PHI Protection", subsection_style))
story.append(Paragraph("<b>Objective:</b> Eliminate PHI from model context; comply with data minimization.", body_style))

phase1_tasks = [
    "Create <font face='Courier'>lib/utils/phi_scrubber.dart</font> with regex patterns for: names (capitalized words), "
    "phone numbers (E.164 + local formats), emails, addresses (street numbers + names), DOBs (MM/DD/YYYY, DD/MM/YYYY), "
    "SSN/NHS numbers.",
    "Implement <font face='Courier'>SanitizedInput scrubAndPrepareInput(String raw)</font> returning a record with "
    "<font face='Courier'>cleanText</font> and <font face='Courier'>redactionMap</font> (for potential re-hydration in UI).",
    "Write unit tests covering: typical medical input, inputs with embedded PII, edge cases (medical terms that look "
    "like PII, e.g., \"Patient John\" → should redact \"John\" but not \"Patient\").",
    "Integrate into <font face='Courier'>LiteRTGemmaEngine.respond()</font> as the first line of execution.",
    "Verify: No PII reaches the native MethodChannel call (add debug logging in debug builds only).",
]

for i, task in enumerate(phase1_tasks, 1):
    story.append(Paragraph(f"{i}. {task}", bullet_style))

# Phase 2
story.append(Paragraph("5.2 Phase 2: Structured Output Pipeline", subsection_style))
story.append(Paragraph("<b>Objective:</b> Enforce machine-parseable, schema-validated model outputs.", body_style))

phase2_tasks = [
    "Define <font face='Courier'>TriageResponse</font> class (Freezed or manual) with fields: "
    "<font face='Courier'>severity (enum), actions (List<String>), nextQuestion (String?), disclaimer (String), "
    "suggestions (List<String>), metadata (Map)</font>.",
    "Define JSON Schema (Draft 2020-12) for the model output and embed it in the system prompt as a strict "
    "formatting instruction.",
    "Update system prompt in <font face='Courier'>triage_engine.dart</font> to require JSON-only output with "
    "explicit field descriptions and examples.",
    "Implement <font face='Courier'>TriageResponse parseAndValidateResponse(String raw)</font> using "
    "<font face='Courier'>dart:convert</font> + schema validator (or manual validation for zero-dep).",
    "Handle parse failures gracefully: fallback to structured error response with <font face='Courier'>severity=unknown</font> "
    "and generic safety actions.",
    "Update UI layer (<font face='Courier'>chat_screen.dart</font>, <font face='Courier'>bubble.dart</font>) to "
    "render structured <font face='Courier'>TriageResponse</font> instead of raw text.",
]

for i, task in enumerate(phase2_tasks, 1):
    story.append(Paragraph(f"{i}. {task}", bullet_style))

# Phase 3
story.append(Paragraph("5.3 Phase 3: Hardened Emergency Overrides", subsection_style))
story.append(Paragraph("<b>Objective:</b> Zero-latency, zero-failure response for life-threatening conditions.", body_style))

phase3_tasks = [
    "Curate a validated keyword/pattern list with medical advisor review: "
    "<font face='Courier'>['can.t breathe', 'cannot breathe', 'shortness of breath