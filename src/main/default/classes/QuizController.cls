public with sharing class QuizController {
    private static final QuizSessionService quizSessionService = new QuizSessionService();
    private static final QuizAnswerService answerService = new QuizAnswerService();
    private static final QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
    private static final QuizPlayerService playerService = new QuizPlayerService();
    private static final QuizSettingsService settingsService = new QuizSettingsService();

    @AuraEnabled(cacheable=true)
    public static Quiz_Settings__mdt getQuizSettings() {
        return settingsService.get();
    }

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getWinnerStats() {
        List<Quiz_Player__c> playerList = playerService.getPlayersSortedByScore(
            1
        );
        if (playerList.isEmpty()) {
            throw new AuraHandledException('No player found');
        }
        try {
            return answerService.getPlayerAnswerStats(playerList[0].Id);
        } catch (QuizAnswerService.UnknownUserException e) {
            throw new AuraHandledException('Unknown player');
        }
    }

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getPlayerAnswerStats(
        Id playerId
    ) {
        if (playerId == null) {
            throw new AuraHandledException('Missing player Id.');
        }
        try {
            return answerService.getPlayerAnswerStats(playerId);
        } catch (QuizAnswerService.UnknownUserException e) {
            throw new AuraHandledException('Unknown player');
        }
    }

    @AuraEnabled
    public static Quiz_Question__c getCurrentQuestion(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return quizSessionService.getCurrentQuestion(sessionId);
    }

    @AuraEnabled
    public static Map<String, Integer> getAnswerStats() {
        return answerService.getAnswerStats();
    }

    @AuraEnabled
    public static List<Quiz_Player__c> getPlayersSortedByScore(
        Integer maxFetchCount
    ) {
        return playerService.getPlayersSortedByScore(maxFetchCount);
    }

    @AuraEnabled
    public static Quiz_Session__c getQuizSession() {
        return quizSessionService.getQuizSession();
    }

    @AuraEnabled
    public static Quiz_Session__c triggerNextPhase(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return quizSessionHelper.triggerNextPhase(sessionId);
    }
}
