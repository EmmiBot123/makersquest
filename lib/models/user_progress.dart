// UserProgress Model for MakerQuest Flutter App

class UserProgress {
  final Set<String> completedProjects;
  final Map<String, Set<String>> checklistState;
  final Map<String, Set<int>> completedSteps;
  final Map<String, String> proofNotes;
  final Map<String, String> proofImages;
  final Set<String> completedChallenges;
  final Map<String, int> challengeScores;

  UserProgress({
    Set<String>? completedProjects,
    Map<String, Set<String>>? checklistState,
    Map<String, Set<int>>? completedSteps,
    Map<String, String>? proofNotes,
    Map<String, String>? proofImages,
    Set<String>? completedChallenges,
    Map<String, int>? challengeScores,
  })  : completedProjects = completedProjects ?? {},
        checklistState = checklistState ?? {},
        completedSteps = completedSteps ?? {},
        proofNotes = proofNotes ?? {},
        proofImages = proofImages ?? {},
        completedChallenges = completedChallenges ?? {},
        challengeScores = challengeScores ?? {};

  bool isProjectCompleted(String projectId) => completedProjects.contains(projectId);
  bool isChallengeCompleted(String challengeId) => completedChallenges.contains(challengeId);

  Set<String> getChecklistFor(String projectId) => checklistState[projectId] ?? {};
  Set<int> getStepsFor(String projectId) => completedSteps[projectId] ?? {};

  UserProgress clone() {
    return UserProgress(
      completedProjects: Set.from(completedProjects),
      checklistState: checklistState.map((k, v) => MapEntry(k, Set.from(v))),
      completedSteps: completedSteps.map((k, v) => MapEntry(k, Set.from(v))),
      proofNotes: Map.from(proofNotes),
      proofImages: Map.from(proofImages),
      completedChallenges: Set.from(completedChallenges),
      challengeScores: Map.from(challengeScores),
    );
  }
}

