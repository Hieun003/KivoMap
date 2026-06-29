// 1. Khung tình huống thực tế (KnowledgeCluster)
final Map<String, dynamic> seedCluster = {
  'category': 'TRAVEL',
  'title': 'Airport Check-in',
  'description': 'Làm thủ tục hành lý và xuất trình giấy tờ tại sân bay.',
  'orderIndex': 1,
};

// 2. Danh sách từ vựng mục tiêu (Vocabularies) - ĐÃ XÓA TRƯỜNG LEVEL
final List<Map<String, dynamic>> seedVocabularies = [
  {
    'id': 'vocab_passport_001',
    'word': 'passport',
    'meaning': 'hộ chiếu',
    'pronunciation': '/ˈpæspɔːrt/',
    'example': 'Please show your passport at the counter.',
  },
  {
    'id': 'vocab_luggage_002',
    'word': 'luggage',
    'meaning': 'hành lý',
    'pronunciation': '/ˈlʌɡɪdʒ/',
    'example': 'You can check in your luggage here.',
  },
  {
    'id': 'vocab_security_003',
    'word': 'security',
    'meaning': 'an ninh',
    'pronunciation': '/sɪˈkjʊrəti/',
    'example': 'Go through security checkpoint.',
  }
];

// 3. Ma trận câu hỏi bối cảnh đan chéo đục lỗ (KnowledgeLinks)
final List<Map<String, dynamic>> seedLinks = [
  {
    'clusterId': '',
    'sourceVocabularyId': 'vocab_passport_001', // passport
    'targetVocabularyId': 'vocab_luggage_002',  // luggage
    'relationType': 'CONTEXT',
    'contextExample': 'We cannot check in your luggage until we verify your [ ? ].',
  },
  {
    'clusterId': '',
    'sourceVocabularyId': 'vocab_passport_001', // passport
    'targetVocabularyId': 'vocab_security_003', // security
    'relationType': 'CONTEXT',
    'contextExample': 'Please show your ID and [ ? ] at the security checkpoint.',
  }
];