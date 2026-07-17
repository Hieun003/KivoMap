import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/energy_service.dart';
import '../../../data/kivo_seed_data.dart';
import '../../../data/user_profile_service.dart';
import '../../../data/vocabulary_learning_service.dart';
import 'profile_view_state.dart';

class ProfileViewModel extends GetxController {
  ProfileViewModel({VocabularyLearningService? learningService, EnergyService? energyService, UserProfileService? profileService})
      : _learningService = learningService ?? Get.find<VocabularyLearningService>(),
        _energyService = energyService ?? Get.find<EnergyService>(),
        _profileService = profileService ?? Get.find<UserProfileService>();
  final VocabularyLearningService _learningService;
  final EnergyService _energyService;
  final UserProfileService _profileService;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<ProfileViewState> state = Rxn<ProfileViewState>();
  Worker? _energyWorker;
  Worker? _streakWorker;
  Worker? _learningWorker;
  Worker? _profileWorker;
  @override void onInit() { super.onInit(); _energyWorker=ever(_energyService.energy, (_) => _updateLiveValues()); _streakWorker=ever(_energyService.streakDays, (_) => _updateLiveValues()); _learningWorker=ever(_learningService.srsUpdateTrigger, (_) => load()); _profileWorker=ever(_profileService.profile, (_) => load()); load(); }
  @override void onClose() { _energyWorker?.dispose(); _streakWorker?.dispose(); _learningWorker?.dispose(); _profileWorker?.dispose(); super.onClose(); }
  Future<void> load() async {
    isLoading.value=true; errorMessage.value=null;
    try {
      await _learningService.initialize(); await _energyService.initialize(); await _profileService.initialize();
      final learned=await _learningService.learnedVocabularyStates(); final due=await _learningService.dueRepetitionStates(); final discoveries=await _learningService.recentDiscoveryActivities();
      final words={for(final v in seedVocabularies) v['id']?.toString() ?? '': v['word']?.toString() ?? 'từ mới'};
      var contextCount=0; for(final v in seedVocabularies){ final id=v['id']?.toString() ?? ''; if(id.isNotEmpty) contextCount+=(await _learningService.discoveredContextIdsFor(id)).length; }
      final activities=<ProfileRecentActivity>[];
      for(final item in learned){ final word=words[item.vocabularyId] ?? 'từ mới'; activities.add(ProfileRecentActivity(title:'Mở khóa từ “$word”', occurredAt:item.learnedAt, type:ProfileActivityType.learned)); if(item.lastReviewedAt case final reviewedAt?) activities.add(ProfileRecentActivity(title:'Ôn lại từ “$word”', occurredAt:reviewedAt, type:ProfileActivityType.reviewed)); }
      for(final item in discoveries){ final word=words[item.vocabularyId] ?? 'từ mới'; activities.add(ProfileRecentActivity(title:'Khám phá bối cảnh của “$word”', occurredAt:item.discoveredAt, type:ProfileActivityType.discovered)); }
      activities.sort((a,b)=>b.occurredAt.compareTo(a.occurredAt)); final user=_profileService.profile.value;
      state.value=ProfileViewState(displayName:user.displayName, profileDescription:'Học tiếng Anh qua ngữ cảnh thực tế', avatarPath:_profileService.avatarFor(user.avatarKey).assetPath, energy:_energyService.energy.value, maxEnergy:EnergyService.maxEnergy, streakDays:_energyService.streakDays.value, unlockedWordCount:learned.length, discoveredContextCount:contextCount, dueReviewCount:due.length, nextAction:due.isNotEmpty?ProfileNextAction.review:ProfileNextAction.discover, recentActivities:List.unmodifiable(activities.take(3)));
    } catch (_) { errorMessage.value='Không thể tải Hồ sơ. Hãy thử lại nhé.'; } finally { isLoading.value=false; }
  }
  void openSettings()=>Get.toNamed<void>(AppRoutes.settings);
  void openPersonalProfile()=>Get.toNamed<void>(AppRoutes.personalProfile);
  void openTreasure()=>Get.offAllNamed<void>(AppRoutes.treasure);
  void openDiscovery()=>Get.offAllNamed<void>(AppRoutes.home);
  void startNextAction(){ if(state.value?.nextAction==ProfileNextAction.review){Get.toNamed<void>(AppRoutes.review);}else{final c=seedClusters.first; Get.toNamed<void>(AppRoutes.vocabularyPlanet,arguments:{'clusterId':c['id'],'title':c['titleVi']??c['title'],'subtitle':'Khám phá từ vựng theo bối cảnh','iconKey':c['iconKey']??'default'});} }
  void _updateLiveValues(){ final current=state.value; if(current==null)return; state.value=ProfileViewState(displayName:current.displayName,profileDescription:current.profileDescription,avatarPath:current.avatarPath,energy:_energyService.energy.value,maxEnergy:EnergyService.maxEnergy,streakDays:_energyService.streakDays.value,unlockedWordCount:current.unlockedWordCount,discoveredContextCount:current.discoveredContextCount,dueReviewCount:current.dueReviewCount,nextAction:current.nextAction,recentActivities:current.recentActivities); }
}
