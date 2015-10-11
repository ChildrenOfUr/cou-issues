part of coufeedback;

List<Map<String, dynamic>> getMatches(String title, List<Map<String, dynamic>> issues) {
	Map<int, Map<String, dynamic>> matchingIssues = {};

	// Iterate through words in title
	String searchTitle = title.trim().toLowerCase();
	searchTitle.split(" ").forEach((String word) {
		// Iterate through issue titles
		issues.forEach((Map<String, dynamic> issue) {
			// Add it to the results if it matches the title
			int percent = getMatchPercent(issue["title"], title);
			if (percent > 0) {
				matchingIssues.addAll(({
					percent: issue
				}));
			}
		});
	});

	return matchingIssues;
}

int getMatchPercent(String a, String b) {
	// Get words in strings
	List<String> aWords = a.trim().toLowerCase().split(" ");
	List<String> bWords = b.trim().toLowerCase().split(" ");

	// Calculate how well it matches up
	int matches = 0;

	// Check every word in string a
	aWords.forEach((String aWord) {
		// To see if it contains any of the parts of words in string b
		bWords.forEach((String bWord) {
			if (bWord.contains(aWord)) {
				// Increment match if it is relevant
				matches++;
			}
		});
	});

	// Find the percent of relevance
	int percent = (100 ~/ issueTitleWords.length) * matches;
	return percent;
}