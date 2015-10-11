part of coufeedback;

class RelatedIssues {
	static List<Map<String, dynamic>> getMatches(String title, List<Map<String, dynamic>> issues) {
		Map<int, Map<String, dynamic>> matchingIssues = {};

		// Iterate through words in title
		String searchTitle = title.trim().toLowerCase();
		searchTitle.split(" ").forEach((String word) {
			// Iterate through issue titles
			issues.forEach((Map<String, dynamic> issue) {
				// Add it to the results if it matches the title
				int percent = _getMatchPercent(issue["title"], title);
				if (percent > 0) {
					matchingIssues.addAll(({
						percent: issue
					}));
				}
			});
		});

		return matchingIssues.values.toList();
	}

	static int _getMatchPercent(String a, String b) {
		// Get words in strings
		List<String> aWords = a.trim().toLowerCase().split(" ");
		List<String> bWords = b.trim().toLowerCase().split(" ");

		// Calculate how well it matches up
		int matches = 0;

		// Check every word in string a
		aWords.forEach((String aWord) {
			// To see if it contains any of the parts of words in string b
			bWords.forEach((String bWord) {
				if (aWord.contains(bWord)) {
					// Increment match if it is relevant
					matches++;
				}
			});
		});

		// Find the percent of relevance
		int percent = (100 ~/ aWords.length) * matches;
		return percent;
	}
}