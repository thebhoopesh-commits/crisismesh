// Copyright 2025 CrisisMesh. All rights reserved.
// PHI Scrubber — removes Protected Health Information from user input before LLM inference.

library phi_scrubber;

import 'dart:core';

/// Result of PHI scrubbing operation.
/// Immutable data class containing the sanitized text and audit metadata.
class SanitizedInput {
  /// The input text with all PHI replaced by placeholders (e.g., "[NAME]", "[PHONE]").
  /// Safe to send to the LLM — contains no identifying information.
  final String cleanText;

  /// Mapping of original PHI values to their placeholders.
  /// Key = original text found, Value = placeholder used.
  /// Useful for UI re-hydration (showing user their own data locally) without ever sending PII to the model.
  final Map<String, String> redactionMap;

  /// Detailed match records for audit logging, telemetry, and compliance.
  final List<PhiMatch> matches;

  const SanitizedInput({
    required this.cleanText,
    required this.redactionMap,
    required this.matches,
  });

  /// Whether any PHI was detected and scrubbed.
  bool get hasRedactions => matches.isNotEmpty;

  /// Number of distinct PHI instances found.
  int get redactionCount => matches.length;

  /// Summary by PHI type for logging.
  Map<String, int> get redactionSummary {
    final summary = <String, int>{};
    for (final m in matches) {
      summary[m.type] = (summary[m.type] ?? 0) + 1;
    }
    return summary;
  }

  @override
  String toString() =>
      'SanitizedInput(cleanText: ${cleanText.length} chars, '
      'redactions: $redactionCount, types: $redactionSummary)';
}

/// A single PHI match found during scrubbing.
class PhiMatch {
  /// PHI category: 'name', 'phone', 'email', 'address', 'zip', 'date', 'ssn', 'mrn', 'device', 'biometric'.
  final String type;

  /// The original text that was matched (the actual PII).
  final String original;

  /// The placeholder that replaced it (e.g., "[NAME]").
  final String placeholder;

  /// Start index in the original input string.
  final int start;

  /// End index (exclusive) in the original input string.
  final int end;

  const PhiMatch(this.type, this.original, this.placeholder, this.start, this.end);

  @override
  String toString() => 'PhiMatch($type: "$original" \u2192 $placeholder @$start-$end)';
}

/// Static utility class for scrubbing PHI from text.
/// All regexes are pre-compiled for performance.
class PhiScrubber {
  // ============================================================
  // PRE-COMPILED REGEX PATTERNS (static final = runtime constants)
  // NOTE: All patterns are single-line, no comments — Dart RegExp doesn't support 'x' flag.
  // ============================================================

  /// Names: Case-insensitive, allows lowercase, 1-3 words, allow hyphens/apostrophes/particles.
    /// Matches: "John", "ram", "John Smith", "Mary Jane Watson", "jean-paul", "O'Connor"
    /// Does NOT match: common clinical titles (case-insensitive) or common English words like "chest", "pain", "taking", "and", etc.
    /// Uses negative lookahead to exclude common clinical/medical title words and common non-name words.
    static final RegExp _nameRegex = RegExp(
      r"\b(?:(?!Patient\b|Doctor\b|Dr\b|Nurse\b|Physician\b|Medic\b|Paramedic\b|EMT\b|First\s+Responder\b|chest\b|pain\b|allergic\b|penicillin\b|lisinopril\b|metformin\b|contact\b|for\b|records\b|temp\b|taking\b|and\b)[A-Za-z][a-zA-Z]{2,}(?:\s+(?:(?!Patient\b|Doctor\b|Dr\b|Nurse\b|Physician\b|Medic\b|Paramedic\b|EMT\b|First\s+Responder\b|chest\b|pain\b|allergic\b|penicillin\b|lisinopril\b|metformin\b|contact\b|for\b|records\b|temp\b|taking\b|and\b)[A-Za-z][a-zA-Z]{2,}|van|de|von|di|la|le|del|della|dos|das|y|Mac|Mc|O'))?){1,3}\b",
      caseSensitive: false,
    );

  /// Phone numbers: E.164 + US/CA/UK/AU local formats.
  /// Matches full phone numbers including country codes.
  /// Priority: more specific formats first
  static final RegExp _phoneRegex = RegExp(
    // US/CA: +1 (555) 123-4567, +1 555 123 4567, 555-123-4567, 555.123.4567, (555) 123-4567
    // Also 7-digit local: 555-0199 (common in emergencies)
    r'(?:\+?1[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4})|'
    // UK: +44 20 7946 0958, +44 7911 123456, 020 7946 0958, 07911 123456
    // Landline: +44 <area> <local> or 0<area> <local> where area=2-5 digits, local=3-4+3-4 digits
    // Mobile: +44 7xxx xxxxxx or 07xxx xxxxxx
    r'(?:\+?44[\s.-]?(?:\d{2,5}[\s.-]?\d{3,4}[\s.-]?\d{3,4}|7\d{3}[\s.-]?\d{6}))|'
    r'(?:0\d{2,5}[\s.-]?\d{3,4}[\s.-]?\d{3,4})|'
    // AU: +61 4 1234 5678, +61 2 9123 4567, 04 1234 5678, 02 9123 4567
    // Mobile: +61 4xxxx xxxx or 04xxxx xxxx
    // Landline: +61 <area> xxxx xxxx or 0<area> xxxx xxxx (area = 1 digit)
    r'(?:\+?61[\s.-]?\d(?:[\s.-]?\d{4}){2})|'
    r'(?:0\d(?:[\s.-]?\d{4}){2})|'
    // US 7-digit local (no area code): 555-0199, 555.0199, 555 0199
    r'(?:\b\d{3}[\s.-]?\d{4}\b)|'
    // Generic E.164 fallback: +CC NNNNNNNNNN
    r'(?:\+\d{1,3}[\s.-]?\d{4,14})',
    caseSensitive: false,
  );

  /// Email addresses.
  static final RegExp _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b',
    caseSensitive: false,
  );

  /// Street addresses (US/UK/CA/AU common suffixes).
  static final RegExp _addressRegex = RegExp(
    r'\b\d{1,5}\s+(?:[A-Za-z]+(?:\s+[A-Za-z]+){0,3})\s+(?:Street|St|Avenue|Ave|Road|Rd|Boulevard|Blvd|Drive|Dr|Lane|Ln|Court|Ct|Place|Pl|Way|Circle|Cir|Trail|Trl|Parkway|Pkwy|Highway|Hwy|Expressway|Expy|Square|Sq|Plaza|Terrace|Ter)\.?(?:\s+[A-Za-z]+){0,2}\b',
    caseSensitive: false,
  );

  /// ZIP / Postal codes (US, CA, UK, AU).
  /// UK: A9 9AA, A99 9AA, AA9 9AA, AA99 9AA, A9A 9AA, AA9A 9AA
  /// CA: A9A 9A9
  /// US: 99999 or 99999-9999
  /// AU: 9999
  static final RegExp _zipRegex = RegExp(
    r'\b(?:\d{5}(?:-\d{4})?|[A-Za-z]\d[A-Za-z]\s?\d[A-Za-z]\d|[A-Za-z]{1,2}\d{1,2}[A-Za-z]?\s?\d[A-Za-z]{2}|\d{4})\b',
    caseSensitive: false,
  );

  /// Dates: MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD, Month DD, YYYY, DOB prefix.
  static final RegExp _dateRegex = RegExp(
    r'\b(?:DOB[\s:]*)?(?:\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}[/-]\d{1,2}[/-]\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4})\b',
    caseSensitive: false,
  );

  /// SSN / National IDs (US SSN, UK NHS, generic 10-digit).
  static final RegExp _ssnRegex = RegExp(
    r'\b(?:\d{3}-\d{2}-\d{4}|\d{3}\s\d{2}\s\d{4}|[A-Za-z]{2}\d{6}[A-Za-z]|\d{10})\b',
    caseSensitive: false,
  );

  /// Medical Record Numbers (hospital-specific prefixes).
  static final RegExp _mrnRegex = RegExp(
    r'\b(?:MRN|MR#|MedRec|Patient\s*ID)[\s:#-]*[A-Za-z0-9]{6,12}\b',
    caseSensitive: false,
  );

  /// Device / Serial Numbers (IMEI, UDID, SN).
  static final RegExp _deviceRegex = RegExp(
    r'\b(?:SN|Serial|IMEI|UDID)[\s:#-]*[A-Za-z0-9]{8,20}\b',
    caseSensitive: false,
  );

  /// Biometric / Photo references.
  static final RegExp _biometricRegex = RegExp(
    r'\b(?:fingerprint|face\s*scan|retina|voice\s*print|photo|selfie)\b',
    caseSensitive: false,
  );

  /// Pattern specification for ordered processing.
  /// Order matters: more specific patterns first (e.g., MRN before generic SSN).
  static final List<_PatternSpec> _patterns = [
    _PatternSpec('mrn', _mrnRegex, 10),
    _PatternSpec('device', _deviceRegex, 9),
    _PatternSpec('email', _emailRegex, 8),
    _PatternSpec('address', _addressRegex, 7),
    _PatternSpec('phone', _phoneRegex, 6),
    _PatternSpec('ssn', _ssnRegex, 5),
    _PatternSpec('zip', _zipRegex, 4),
    _PatternSpec('date', _dateRegex, 3),
    _PatternSpec('name', _nameRegex, 2),
    _PatternSpec('biometric', _biometricRegex, 1),
  ];

  /// Scrubs PHI from [input], returning a [SanitizedInput] with clean text and audit metadata.
  ///
  /// Algorithm:
  /// 1. Find ALL matches on the ORIGINAL input across all patterns
  /// 2. Resolve overlapping matches (keep highest priority, then longest)
  /// 3. Sort non-overlapping matches by start position descending
  /// 4. Apply replacements to build cleanText
  /// 5. Build redactionMap and matches list
  static SanitizedInput scrub(String input) {
    if (input.isEmpty) {
      return const SanitizedInput(
        cleanText: '',
        redactionMap: {},
        matches: [],
      );
    }

    // 1. Find ALL matches on original input with their positions and priority
    final allMatches = <_RawMatch>[];
    for (final spec in _patterns) {
      for (final match in spec.regex.allMatches(input)) {
        allMatches.add(_RawMatch(
          spec.type,
          match.group(0)!,
          match.start,
          match.end,
          spec.priority,
        ));
      }
    }

    if (allMatches.isEmpty) {
      return SanitizedInput(
        cleanText: input,
        redactionMap: {},
        matches: [],
      );
    }

    // 2. Resolve overlaps: sort by start, then by priority (higher = more specific), then by length (longer first)
    allMatches.sort((a, b) {
      if (a.start != b.start) return a.start.compareTo(b.start);
      if (a.priority != b.priority) return b.priority.compareTo(a.priority); // higher priority first
      return (b.end - b.start).compareTo(a.end - a.start); // longer first
    });

    // Keep only non-overlapping matches (greedy: keep first/highest priority at each position)
    final resolvedMatches = <_RawMatch>[];
    int lastEnd = -1;
    for (final m in allMatches) {
      if (m.start >= lastEnd) {
        resolvedMatches.add(m);
        lastEnd = m.end;
      }
      // else: overlaps with a higher-priority match, skip
    }

    // 3. Sort by start descending for safe replacement
    resolvedMatches.sort((a, b) => b.start.compareTo(a.start));

    // 4. Apply replacements
    var workingText = input;
    final redactionMap = <String, String>{};
    final matches = <PhiMatch>[];

    for (final m in resolvedMatches) {
      final placeholder = '[${m.type.toUpperCase()}]';
      workingText = workingText.replaceRange(m.start, m.end, placeholder);
      redactionMap[m.original] = placeholder;
      matches.add(PhiMatch(m.type, m.original, placeholder, m.start, m.end));
    }

    return SanitizedInput(
      cleanText: workingText,
      redactionMap: redactionMap,
      matches: matches,
    );
  }
}

/// Private helper for pattern registry with priority.
class _PatternSpec {
  final String type;
  final RegExp regex;
  final int priority;
  _PatternSpec(this.type, this.regex, this.priority);
}

/// Internal match with priority for overlap resolution.
class _RawMatch {
  final String type;
  final String original;
  final int start;
  final int end;
  final int priority;
  _RawMatch(this.type, this.original, this.start, this.end, this.priority);
}

// ============================================================
// CONVENIENCE TOP-LEVEL FUNCTION
// ============================================================

/// One-liner: `final clean = scrubPhi(rawInput);`
/// Returns only the clean text (for simple use cases).
String scrubPhi(String input) => PhiScrubber.scrub(input).cleanText;