const kivoSeedVersion = '2026-06-30-firestore-iconkey-003';

const seedClusters = [
  {
    'id': 'cluster_airport_checkin',
    'category': 'TRAVEL',
    'title': 'Airport Check-in',
    'iconKey': 'airport_check_in',
    'description': 'Handle luggage, documents, and security at the airport.',
    'orderIndex': 1,
  },
];

const seedVocabularies = [
  {
    'id': 'vocab_passport',
    'clusterId': 'cluster_airport_checkin',
    'word': 'passport',
    'meaning': 'ho chieu',
    'pronunciation': '/PAS-port/',
    'example': 'Please show your passport at the counter.',
    'displayLabel': 'passport / ID',
    'iconKey': 'identity_document',
    'defaultIconKey': 'identity_document',
    'senseKey': 'travel_identity_document',
    'orderIndex': 1,
  },
  {
    'id': 'vocab_luggage',
    'clusterId': 'cluster_airport_checkin',
    'word': 'luggage',
    'meaning': 'hanh ly',
    'pronunciation': '/LUG-ij/',
    'example': 'You can check in your luggage here.',
    'displayLabel': 'luggage / bag',
    'iconKey': 'luggage',
    'defaultIconKey': 'luggage',
    'senseKey': 'travel_baggage',
    'orderIndex': 2,
  },
  {
    'id': 'vocab_security',
    'clusterId': 'cluster_airport_checkin',
    'word': 'security',
    'meaning': 'an ninh',
    'pronunciation': '/si-KYUR-i-tee/',
    'example': 'Go through the security checkpoint.',
    'displayLabel': 'security / checkpoint',
    'iconKey': 'security_check',
    'defaultIconKey': 'security_check',
    'senseKey': 'airport_security_process',
    'orderIndex': 3,
  },
  {
    'id': 'vocab_boarding_pass',
    'clusterId': 'cluster_airport_checkin',
    'word': 'boarding pass',
    'meaning': 'the len may bay',
    'pronunciation': '/BOR-ding pass/',
    'example': 'Keep your boarding pass ready.',
    'displayLabel': 'boarding pass / gate',
    'iconKey': 'ticket',
    'defaultIconKey': 'ticket',
    'senseKey': 'flight_boarding_document',
    'orderIndex': 4,
  },
  {
    'id': 'vocab_counter',
    'clusterId': 'cluster_airport_checkin',
    'word': 'counter',
    'meaning': 'quay lam thu tuc',
    'pronunciation': '/KOWN-ter/',
    'example': 'The check-in counter opens at six.',
    'displayLabel': 'counter / check-in',
    'iconKey': 'check_in_counter',
    'defaultIconKey': 'check_in_counter',
    'senseKey': 'service_counter',
    'orderIndex': 5,
  },
];

const seedKnowledgeLinks = [
  // --- passport (3 links) ---
  {
    'id': 'link_passport_001',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_passport',
    'contextExample':
        'We need to verify your passport before printing the boarding pass.',
    'maskedText':
        'We need to verify your [ ? ] before printing the boarding pass.',
    'answerLabel': 'passport / ID',
    'contextualIconKey': 'identity_document',
    'keywords': ['verify', 'boarding pass'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_passport_002',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_passport',
    'contextExample': 'Please keep your passport open at the photo page.',
    'maskedText': 'Please keep your [ ? ] open at the photo page.',
    'answerLabel': 'passport / ID',
    'contextualIconKey': 'identity_document',
    'keywords': ['photo page'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_passport_003',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_passport',
    'contextExample': 'Your passport name must match the ticket name.',
    'maskedText': 'Your [ ? ] name must match the ticket name.',
    'answerLabel': 'passport / ID',
    'contextualIconKey': 'identity_document',
    'keywords': ['ticket name'],
    'relationType': 'CONTEXT',
  },
  // --- luggage (3 links) ---
  {
    'id': 'link_luggage_001',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_luggage',
    'contextExample': 'Put your luggage on the scale so we can weigh it.',
    'maskedText': 'Put your [ ? ] on the scale so we can weigh it.',
    'answerLabel': 'luggage / bag',
    'contextualIconKey': 'luggage',
    'keywords': ['scale', 'weigh'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_luggage_002',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_luggage',
    'contextExample': 'Your luggage is two kilos over the limit.',
    'maskedText': 'Your [ ? ] is two kilos over the limit.',
    'answerLabel': 'luggage / bag',
    'contextualIconKey': 'luggage',
    'keywords': ['kilos', 'limit'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_luggage_003',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_luggage',
    'contextExample': 'Fragile luggage should be marked before check-in.',
    'maskedText': 'Fragile [ ? ] should be marked before check-in.',
    'answerLabel': 'luggage / bag',
    'contextualIconKey': 'luggage',
    'keywords': ['fragile', 'check-in'],
    'relationType': 'CONTEXT',
  },
  // --- security (3 links) ---
  {
    'id': 'link_security_001',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_security',
    'contextExample':
        'Go through security after you receive your boarding pass.',
    'maskedText': 'Go through [ ? ] after you receive your boarding pass.',
    'answerLabel': 'security / checkpoint',
    'contextualIconKey': 'security_check',
    'keywords': ['go through', 'boarding pass'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_security_002',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_security',
    'contextExample': 'Security may ask you to remove your laptop.',
    'maskedText': '[ ? ] may ask you to remove your laptop.',
    'answerLabel': 'security / checkpoint',
    'contextualIconKey': 'security_officer',
    'keywords': ['remove', 'laptop'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_security_003',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_security',
    'contextExample': 'The security line is shorter near gate B.',
    'maskedText': 'The [ ? ] line is shorter near gate B.',
    'answerLabel': 'security / checkpoint',
    'contextualIconKey': 'security_line',
    'keywords': ['line', 'gate'],
    'relationType': 'CONTEXT',
  },
  // --- boarding_pass (3 links) ---
  {
    'id': 'link_boarding_pass_001',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_boarding_pass',
    'contextExample': 'Please have your boarding pass ready at the gate.',
    'maskedText': 'Please have your [ ? ] ready at the gate.',
    'answerLabel': 'boarding pass / gate',
    'contextualIconKey': 'ticket',
    'keywords': ['ready', 'gate'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_boarding_pass_002',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_boarding_pass',
    'contextExample': 'You can show a digital boarding pass on your phone.',
    'maskedText': 'You can show a digital [ ? ] on your phone.',
    'answerLabel': 'boarding pass / gate',
    'contextualIconKey': 'mobile_ticket',
    'keywords': ['digital', 'phone'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_boarding_pass_003',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_boarding_pass',
    'contextExample': 'The agent printed my boarding pass at the counter.',
    'maskedText': 'The agent printed my [ ? ] at the counter.',
    'answerLabel': 'boarding pass / gate',
    'contextualIconKey': 'ticket',
    'keywords': ['printed', 'counter'],
    'relationType': 'CONTEXT',
  },
  // --- counter (3 links) ---
  {
    'id': 'link_counter_001',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_counter',
    'contextExample': 'Please proceed to the check-in counter with your bags.',
    'maskedText': 'Please proceed to the check-in [ ? ] with your bags.',
    'answerLabel': 'counter / check-in',
    'contextualIconKey': 'check_in_counter',
    'keywords': ['proceed', 'bags'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_counter_002',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_counter',
    'contextExample': 'The counter closes 45 minutes before departure.',
    'maskedText': 'The [ ? ] closes 45 minutes before departure.',
    'answerLabel': 'counter / check-in',
    'contextualIconKey': 'check_in_counter',
    'keywords': ['closes', 'departure'],
    'relationType': 'CONTEXT',
  },
  {
    'id': 'link_counter_003',
    'clusterId': 'cluster_airport_checkin',
    'vocabularyId': 'vocab_counter',
    'contextExample': 'There is a long queue at the counter this morning.',
    'maskedText': 'There is a long queue at the [ ? ] this morning.',
    'answerLabel': 'counter / check-in',
    'contextualIconKey': 'queue',
    'keywords': ['queue', 'morning'],
    'relationType': 'CONTEXT',
  },
];

const seedContextDetails = [
  // --- passport (3 details) ---
  {
    'id': 'link_passport_001',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'May I see your passport, please?'},
      {'speaker': 'Traveler', 'text': 'Sure, here it is.'},
    ],
    'realWorldTip':
        'At check-in, passport is usually requested before baggage handling.',
    'audioUrl': null,
  },
  {
    'id': 'link_passport_002',
    'miniDialogue': [
      {
        'speaker': 'Agent',
        'text': 'Please open your passport to the photo page.',
      },
      {'speaker': 'Traveler', 'text': 'Of course, one moment.'},
    ],
    'realWorldTip':
        'The photo page is the main data page - agents need to verify your identity.',
    'audioUrl': null,
  },
  {
    'id': 'link_passport_003',
    'miniDialogue': [
      {
        'speaker': 'Agent',
        'text': 'The name on your passport must match the ticket exactly.',
      },
      {'speaker': 'Traveler', 'text': 'Yes, I double-checked before booking.'},
    ],
    'realWorldTip':
        'Always book tickets using the exact name on your passport to avoid check-in issues.',
    'audioUrl': null,
  },
  // --- luggage (3 details) ---
  {
    'id': 'link_luggage_001',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Please put your luggage on the scale.'},
      {'speaker': 'Traveler', 'text': 'Is this one too heavy?'},
    ],
    'realWorldTip': 'Scale and weight limit are strong clues for luggage.',
    'audioUrl': null,
  },
  {
    'id': 'link_luggage_002',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Your luggage is two kilos over the limit.'},
      {'speaker': 'Traveler', 'text': 'Can I move some items to my carry-on?'},
    ],
    'realWorldTip':
        'Most airlines allow 20-23 kg for checked luggage. Excess weight incurs extra fees.',
    'audioUrl': null,
  },
  {
    'id': 'link_luggage_003',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Is your luggage fragile?'},
      {'speaker': 'Traveler', 'text': 'Yes, please mark it fragile.'},
    ],
    'realWorldTip':
        'Ask for a fragile sticker at the counter to ensure careful handling.',
    'audioUrl': null,
  },
  // --- security (3 details) ---
  {
    'id': 'link_security_001',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Security is after this counter.'},
      {'speaker': 'Traveler', 'text': 'Do I need to remove my laptop?'},
    ],
    'realWorldTip':
        'Security often appears with checkpoint, laptop, belt, and gate.',
    'audioUrl': null,
  },
  {
    'id': 'link_security_002',
    'miniDialogue': [
      {'speaker': 'Officer', 'text': 'Please remove your laptop from the bag.'},
      {'speaker': 'Traveler', 'text': 'Sure, I will place it in the tray.'},
    ],
    'realWorldTip':
        'Laptops and liquids over 100ml must be removed at security checkpoints.',
    'audioUrl': null,
  },
  {
    'id': 'link_security_003',
    'miniDialogue': [
      {
        'speaker': 'Traveler',
        'text': 'Is the security line near gate B shorter?',
      },
      {'speaker': 'Staff', 'text': 'Yes, use the priority lane on the left.'},
    ],
    'realWorldTip':
        'Some airports have multiple security lanes - check for shorter queues.',
    'audioUrl': null,
  },
  // --- boarding_pass (3 details) ---
  {
    'id': 'link_boarding_pass_001',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Please have your boarding pass ready.'},
      {'speaker': 'Traveler', 'text': 'I have it on my phone.'},
    ],
    'realWorldTip':
        'Digital boarding passes are accepted at most airports. Screenshot it in case of no signal.',
    'audioUrl': null,
  },
  {
    'id': 'link_boarding_pass_002',
    'miniDialogue': [
      {'speaker': 'Traveler', 'text': 'Can I use a digital boarding pass?'},
      {'speaker': 'Agent', 'text': 'Yes, just show it on your phone screen.'},
    ],
    'realWorldTip':
        'Check in online 24 hours before departure to get your boarding pass early.',
    'audioUrl': null,
  },
  {
    'id': 'link_boarding_pass_003',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'Here is your boarding pass. Gate B12.'},
      {
        'speaker': 'Traveler',
        'text': 'Thank you. What time does boarding start?',
      },
    ],
    'realWorldTip':
        'Your boarding pass shows the gate, seat number, and boarding time.',
    'audioUrl': null,
  },
  // --- counter (3 details) ---
  {
    'id': 'link_counter_001',
    'miniDialogue': [
      {'speaker': 'Staff', 'text': 'Please go to counter 5 for check-in.'},
      {'speaker': 'Traveler', 'text': 'Thank you, I will head there now.'},
    ],
    'realWorldTip':
        'Check your airline app or the departures board for your check-in counter number.',
    'audioUrl': null,
  },
  {
    'id': 'link_counter_002',
    'miniDialogue': [
      {'speaker': 'Agent', 'text': 'The counter closes in 10 minutes.'},
      {'speaker': 'Traveler', 'text': 'I am here now. Can I still check in?'},
    ],
    'realWorldTip':
        'Arrive at the counter at least 60-90 minutes before departure to avoid cutoff.',
    'audioUrl': null,
  },
  {
    'id': 'link_counter_003',
    'miniDialogue': [
      {'speaker': 'Traveler', 'text': 'The queue at the counter is very long.'},
      {'speaker': 'Friend', 'text': 'Try the self-service kiosk instead.'},
    ],
    'realWorldTip':
        'Self-service kiosks can save time when counter queues are long.',
    'audioUrl': null,
  },
];
