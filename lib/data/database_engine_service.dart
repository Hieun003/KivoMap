import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'kivo_seed_data.dart';

class DatabaseEngineService {
  DatabaseEngineService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _clusters =>
      _firestore.collection('knowledge_clusters');

  CollectionReference<Map<String, dynamic>> get _knowledgeLinks =>
      _firestore.collection('knowledge_links');

  CollectionReference<Map<String, dynamic>> get _contextDetails =>
      _firestore.collection('context_details');

  CollectionReference<Map<String, dynamic>> get _passagewayCombos =>
      _firestore.collection('passageway_combos');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> seedStaticKnowledgeBase() async {
    final seedRef = _firestore.collection('system').doc('seed_status');
    final seedSnapshot = await seedRef.get();

    if (seedSnapshot.data()?['version'] == kivoSeedVersion) {
      return;
    }

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    for (final cluster in seedClusters) {
      final clusterId = cluster['id'] as String;
      final data = Map<String, dynamic>.from(cluster)..remove('id');

      batch.set(_clusters.doc(clusterId), {
        ...data,
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    }

    for (final vocabulary in seedVocabularies) {
      final vocabId = vocabulary['id'] as String;
      final clusterId = vocabulary['clusterId'] as String;
      final data = Map<String, dynamic>.from(vocabulary)..remove('id');

      batch.set(
        _clusters.doc(clusterId).collection('vocabularies').doc(vocabId),
        {...data, 'isActive': true, 'createdAt': now, 'updatedAt': now},
        SetOptions(merge: true),
      );
    }

    for (final link in seedKnowledgeLinks) {
      final linkId = link['id'] as String;
      final data = Map<String, dynamic>.from(link)..remove('id');

      batch.set(_knowledgeLinks.doc(linkId), {
        ...data,
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    }

    for (final detail in seedContextDetails) {
      final detailId = detail['id'] as String;
      final data = Map<String, dynamic>.from(detail)..remove('id');

      batch.set(_contextDetails.doc(detailId), {
        ...data,
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    }

    batch.set(seedRef, {
      'version': kivoSeedVersion,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> activateUserRuntimeEnvironment({
    required String userId,
    required String name,
    required String email,
  }) async {
    final userRef = _users.doc(userId);
    final progressRef = _progressRef(userId);
    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final progressSnapshot = await transaction.get(progressRef);

      if (!userSnapshot.exists) {
        transaction.set(userRef, {
          'name': name,
          'email': email,
          'isNewbieDiscover': true,
          'createdAt': now,
          'updatedAt': now,
        });
      } else {
        transaction.set(userRef, {
          'name': name,
          'email': email,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }

      if (!progressSnapshot.exists) {
        transaction.set(progressRef, {
          'learnedWords': 0,
          'reviewedWords': 0,
          'stamina': 100,
          'explorerTitle': 'Word Explorer',
          'streakDays': 0,
          'lastActivityAt': null,
          'updatedAt': now,
        });
      }
    });
  }

  Future<void> bootstrapFirestoreSchema({required String userId}) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    final schemaDoc = {
      'isSchemaPlaceholder': true,
      'purpose':
          'Keeps the Firestore collection visible before real data exists.',
      'createdAt': now,
      'updatedAt': now,
    };

    batch.set(
      _users.doc(userId).collection('repetition_states').doc('_schema'),
      {
        ...schemaDoc,
        'vocabularyId': null,
        'masteryLevel': 0,
        'intervalDays': 0,
        'easinessFactor': 0,
        'reviewCount': 0,
        'nextReviewAt': null,
        'lastReviewedAt': null,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _users.doc(userId).collection('review_records').doc('_schema'),
      {
        ...schemaDoc,
        'vocabularyId': null,
        'knowledgeLinkId': null,
        'rating': null,
        'selectedAnswer': null,
        'reviewedAt': null,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _users.doc(userId).collection('discovery_traces').doc('_schema'),
      {
        ...schemaDoc,
        'knowledgeLinkId': null,
        'vocabularyId': null,
        'discoveredAt': null,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _users.doc(userId).collection('passageway_progress').doc('_schema'),
      {
        ...schemaDoc,
        'comboId': null,
        'maxStageCleared': 0,
        'isCompleted': false,
      },
      SetOptions(merge: true),
    );

    batch.set(_passagewayCombos.doc('_schema'), {
      ...schemaDoc,
      'title': null,
      'description': null,
      'requiredLearnedWords': 0,
      'energyReward': 0,
      'orderIndex': 0,
    }, SetOptions(merge: true));

    batch.set(
      _passagewayCombos.doc('_schema').collection('stages').doc('_schema'),
      {
        ...schemaDoc,
        'comboId': '_schema',
        'stageIndex': 0,
        'godSpeech': null,
        'choices': const <String>[],
        'correctIndex': null,
      },
      SetOptions(merge: true),
    );

    batch.set(
      _firestore.collection('system').doc('schema_status'),
      {
        'version': kivoSeedVersion,
        'bootstrappedUserId': userId,
        'collections': const [
          'users',
          'users/{userId}/progress',
          'users/{userId}/repetition_states',
          'users/{userId}/review_records',
          'users/{userId}/discovery_traces',
          'users/{userId}/passageway_progress',
          'knowledge_clusters',
          'knowledge_clusters/{clusterId}/vocabularies',
          'knowledge_links',
          'context_details',
          'passageway_combos',
          'passageway_combos/{comboId}/stages',
        ],
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchClusters() {
    return _clusters.orderBy('orderIndex').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchClusterVocabularies(
    String clusterId,
  ) {
    return _clusters
        .doc(clusterId)
        .collection('vocabularies')
        .where('isActive', isEqualTo: true)
        .orderBy('orderIndex')
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchDueReviewStates({
    required String userId,
    int limit = 20,
  }) {
    return _users
        .doc(userId)
        .collection('repetition_states')
        .where('nextReviewAt', isLessThanOrEqualTo: Timestamp.now())
        .limit(limit)
        .get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  buildReviewContextsForVocabulary({
    required String vocabularyId,
    int minItems = 3,
    int maxItems = 5,
  }) async {
    final snapshot = await _knowledgeLinks
        .where('vocabularyId', isEqualTo: vocabularyId)
        .where('isActive', isEqualTo: true)
        .get();

    final docs = [...snapshot.docs]..shuffle(Random());
    final takeCount = min(maxItems, docs.length);

    if (takeCount < minItems) {
      throw StateError(
        'Vocabulary $vocabularyId needs at least $minItems context links.',
      );
    }

    return docs.take(takeCount).toList(growable: false);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAnswerOptionsForCluster({
    required String clusterId,
  }) {
    return _firestore
        .collectionGroup('vocabularies')
        .where('clusterId', isEqualTo: clusterId)
        .where('isActive', isEqualTo: true)
        .get();
  }

  Future<void> recordDiscovery({
    required String userId,
    required String knowledgeLinkId,
    required String vocabularyId,
    int staminaCost = 1,
  }) async {
    final traceRef = _users
        .doc(userId)
        .collection('discovery_traces')
        .doc(knowledgeLinkId);
    final repetitionRef = _repetitionRef(userId, vocabularyId);
    final progressRef = _progressRef(userId);
    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      final traceSnapshot = await transaction.get(traceRef);
      final repetitionSnapshot = await transaction.get(repetitionRef);

      if (!traceSnapshot.exists) {
        transaction.set(traceRef, {
          'knowledgeLinkId': knowledgeLinkId,
          'vocabularyId': vocabularyId,
          'discoveredAt': now,
        });

        transaction.set(progressRef, {
          'learnedWords': FieldValue.increment(1),
          'stamina': FieldValue.increment(-staminaCost),
          'lastActivityAt': now,
          'updatedAt': now,
        }, SetOptions(merge: true));
      }

      if (!repetitionSnapshot.exists) {
        transaction.set(repetitionRef, {
          'vocabularyId': vocabularyId,
          'masteryLevel': 1,
          'intervalDays': 1,
          'easinessFactor': 2.5,
          'reviewCount': 0,
          'nextReviewAt': Timestamp.now(),
          'lastReviewedAt': null,
          'createdAt': now,
          'updatedAt': now,
        });
      }
    });
  }

  Future<void> completeVocabularyReview({
    required String userId,
    required String vocabularyId,
    required List<ReviewAttemptInput> attempts,
  }) async {
    if (attempts.isEmpty) {
      throw ArgumentError.value(attempts, 'attempts', 'Cannot be empty.');
    }

    final repetitionRef = _repetitionRef(userId, vocabularyId);
    final progressRef = _progressRef(userId);
    final allCorrect = attempts.every((attempt) => attempt.isCorrect);
    final now = Timestamp.now();
    final serverNow = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      final repetitionSnapshot = await transaction.get(repetitionRef);
      final current = repetitionSnapshot.data() ?? const <String, dynamic>{};

      final currentMastery = (current['masteryLevel'] as num?)?.toInt() ?? 1;
      final currentInterval = (current['intervalDays'] as num?)?.toInt() ?? 1;
      final currentEase =
          (current['easinessFactor'] as num?)?.toDouble() ?? 2.5;
      final currentReviewCount = (current['reviewCount'] as num?)?.toInt() ?? 0;

      final nextInterval = allCorrect ? max(1, currentInterval * 2) : 1;
      final nextEase = allCorrect
          ? min(3.0, currentEase + 0.1)
          : max(1.3, currentEase - 0.2);
      final nextMastery = allCorrect
          ? min(10, currentMastery + 1)
          : max(1, currentMastery - 1);

      for (final attempt in attempts) {
        final recordRef = _users.doc(userId).collection('review_records').doc();
        transaction.set(recordRef, {
          'vocabularyId': vocabularyId,
          'knowledgeLinkId': attempt.knowledgeLinkId,
          'rating': attempt.isCorrect ? 'CORRECT' : 'INCORRECT',
          'selectedAnswer': attempt.selectedAnswer,
          'reviewedAt': serverNow,
        });
      }

      transaction.set(repetitionRef, {
        'vocabularyId': vocabularyId,
        'masteryLevel': nextMastery,
        'intervalDays': nextInterval,
        'easinessFactor': nextEase,
        'reviewCount': currentReviewCount + 1,
        'nextReviewAt': Timestamp.fromDate(
          now.toDate().add(Duration(days: nextInterval)),
        ),
        'lastReviewedAt': serverNow,
        'updatedAt': serverNow,
      }, SetOptions(merge: true));

      transaction.set(progressRef, {
        'reviewedWords': FieldValue.increment(1),
        'lastActivityAt': serverNow,
        'updatedAt': serverNow,
      }, SetOptions(merge: true));
    });
  }

  DocumentReference<Map<String, dynamic>> _progressRef(String userId) {
    return _users.doc(userId).collection('progress').doc('main');
  }

  DocumentReference<Map<String, dynamic>> _repetitionRef(
    String userId,
    String vocabularyId,
  ) {
    return _users.doc(userId).collection('repetition_states').doc(vocabularyId);
  }
}

class ReviewAttemptInput {
  const ReviewAttemptInput({
    required this.knowledgeLinkId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  final String knowledgeLinkId;
  final String selectedAnswer;
  final bool isCorrect;
}
