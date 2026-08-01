enum Category { medicalTriage, securityIncident, offTopic }

class TrieNode {
  final String id;
  final String prompt;
  final Map<String, String> edges = {};

  TrieNode({required this.id, required this.prompt});

  void link(String answer, String nextNodeId) {
    edges[answer] = nextNodeId;
  }
}

class DecisionTree {
  final Category category;
  final String entryNodeId;
  final Map<String, TrieNode> nodes;

  DecisionTree({
    required this.category,
    required this.entryNodeId,
    required this.nodes,
  });
}

class TriageSystem {
  final Map<Category, DecisionTree> trees = {};
  
  // Current session state
  Category? currentCategory;
  String? currentNodeId;

  void initializeTrees() {
    trees[Category.medicalTriage] = _createMedicalTree();
    trees[Category.securityIncident] = _createSecurityBreachTree();
  }

  void resetSession() {
    currentCategory = null;
    currentNodeId = null;
  }

  /// Classifies intent and moves the state machine forward
  (String, List<String>) processMessage(String message) {
    // 1. If not in a flow, classify the intent
    if (currentCategory == null) {
      currentCategory = _classifyIntent(message);
      
      if (currentCategory == Category.offTopic) {
        currentCategory = null; // Reset
        return ("I am an emergency triage system. Please describe the emergency (e.g., 'I hit my head' or 'There is a fire').", ["I am bleeding", "There is smoke"]);
      }
      
      // Start at the entry node for the chosen category
      currentNodeId = trees[currentCategory!]!.entryNodeId;
      return (trees[currentCategory!]!.nodes[currentNodeId!]!.prompt, ["Yes", "No"]);
    }

    // 2. If already in a flow, extract the answer and step forward
    final tree = trees[currentCategory!]!;
    final currentNode = tree.nodes[currentNodeId!]!;
    
    // Simulate LLM extracting yes/no
    final answer = _simulateAnswerExtraction(message);
    
    if (answer == 'unclear') {
      return ("I didn't quite catch that. ${currentNode.prompt}", ["Yes", "No"]);
    }
    if (answer == 'not_applicable') {
      return ("Please answer Yes or No. ${currentNode.prompt}", ["Yes", "No"]);
    }

    final nextNodeId = currentNode.edges[answer];
    if (nextNodeId == null) {
      // Reached an end state or invalid state
      resetSession();
      return ("Thank you. The information has been logged and prioritized.", ["Start over"]);
    }

    currentNodeId = nextNodeId;
    final nextNode = tree.nodes[nextNodeId]!;
    
    // If next node is a terminal node, reset session
    if (nextNode.id.startsWith('end_')) {
      String resolution = _getTerminalMessage(nextNode.id);
      resetSession();
      return (resolution, ["Report new incident"]);
    }

    return (nextNode.prompt, ["Yes", "No"]);
  }

  static Category _classifyIntent(String message) {
    final m = message.toLowerCase();
    if (m.contains('head') || m.contains('blood') || m.contains('hurt') || m.contains('breathe') || m.contains('pain')) {
      return Category.medicalTriage;
    }
    if (m.contains('fire') || m.contains('smoke') || m.contains('intruder') || m.contains('gun') || m.contains('threat')) {
      return Category.securityIncident;
    }
    return Category.offTopic;
  }

  static String _simulateAnswerExtraction(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('yes') || lower.contains('yeah') || lower.contains('yep')) return 'yes';
    if (lower.contains('no') || lower.contains('nope')) return 'no';
    if (lower.contains('i might') || lower.contains('not sure')) return 'unclear';
    return 'not_applicable';
  }
  
  static String _getTerminalMessage(String endId) {
    switch (endId) {
      case 'end_green':
        return "You are stable. Please walk to the designated safe area.";
      case 'end_red':
        return "CRITICAL: Stay where you are. I have dispatched emergency personnel to your exact location.";
      case 'end_yellow':
        return "URGENT: Please sit down and rest. A medic will be with you shortly.";
      case 'end_rest':
        return "You appear stable, but please rest. We are monitoring the situation.";
      case 'end_active_threat':
        return "CRITICAL SECURITY: Active threat identified. Law enforcement is dispatched. Seek immediate cover.";
      case 'end_safe_shelter':
        return "Please remain sheltered in place until the all-clear is given.";
      default:
        return "Information logged and sent to dispatch.";
    }
  }

  static DecisionTree _createMedicalTree() {
    const ENTRY = "q_mobility";
    final nodes = <String, TrieNode>{
      ENTRY: TrieNode(id: ENTRY, prompt: "Are you able to get up and walk right now?"),
      'q_breathing': TrieNode(id: 'q_breathing', prompt: "Is the person breathing normally?"),
      'q_mental_status': TrieNode(id: 'q_mental_status', prompt: "Can you tell me what day it is and where you are?"),
      'q_dizzy': TrieNode(id: 'q_dizzy', prompt: "Do you feel dizzy or nauseous?"),
      'end_green': TrieNode(id: 'end_green', prompt: ''),
      'end_red': TrieNode(id: 'end_red', prompt: ''),
      'end_yellow': TrieNode(id: 'end_yellow', prompt: ''),
      'end_rest': TrieNode(id: 'end_rest', prompt: ''),
    };

    var qMobility = nodes['q_mobility']!;
    qMobility.link('yes', 'end_green');
    qMobility.link('no', 'q_breathing');

    var qBreathing = nodes['q_breathing']!;
    qBreathing.link('yes', 'q_mental_status');
    qBreathing.link('no', 'end_red');

    var qMentalStatus = nodes['q_mental_status']!;
    qMentalStatus.link('yes', 'q_dizzy');
    qMentalStatus.link('no', 'end_red');

    var qDizzy = nodes['q_dizzy']!;
    qDizzy.link('yes', 'end_yellow');
    qDizzy.link('no', 'end_rest');

    return DecisionTree(category: Category.medicalTriage, entryNodeId: ENTRY, nodes: nodes);
  }

  static DecisionTree _createSecurityBreachTree() {
    const ENTRY = "s_presence";
    final nodes = <String, TrieNode>{
      ENTRY: TrieNode(id: ENTRY, prompt: "Do you see any immediate threats (e.g., smoke, open fire, hostile presence)?"),
      'p_source': TrieNode(id: 'p_source', prompt: "Is the threat coming from outside or is it internal to this building? (Reply 'internal' or 'external')"),
      'p_weapon': TrieNode(id: 'p_weapon', prompt: "Are you armed with a means of defense?"),
      'end_active_threat': TrieNode(id: 'end_active_threat', prompt: ''),
      'end_safe_shelter': TrieNode(id: 'end_safe_shelter', prompt: ''),
    };

    var sPresence = nodes[ENTRY]!;
    sPresence.link('yes', 'p_source');
    sPresence.link('no', 'end_safe_shelter');

    var pSource = nodes['p_source']!;
    pSource.link('internal', 'p_weapon');
    pSource.link('external', 'end_active_threat');

    var pWeapon = nodes['p_weapon']!;
    pWeapon.link('yes', 'end_active_threat');
    pWeapon.link('no', 'end_safe_shelter');

    return DecisionTree(category: Category.securityIncident, entryNodeId: ENTRY, nodes: nodes);
  }
}
