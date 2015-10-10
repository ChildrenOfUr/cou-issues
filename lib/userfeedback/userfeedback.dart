library FeedbackReporter;

import "dart:async";
import "dart:convert";
import "dart:html";
import "package:polymer/polymer.dart";
import "package:transmit/transmit.dart";

@CustomTag("user-feedback")
class UserFeedback extends PolymerElement {
	FormElement _form;
	InputElement _title;
	TextAreaElement _description;
	UrlInputElement _screenshotUrl;
	SelectElement _category;
	DialogElement _preview;
	List<Map<String, dynamic>> _issuesCache;
	@published String username, useragent, log;
	@published int matchingIssue = -1;
	@published bool showMatches = false;

	UserFeedback.created() : super.created() {
		_form = shadowRoot.querySelector("form")
			..onSubmit.listen((Event e) => submitForm(e));
		_title = _form.querySelector("#title input")
			..onInput.listen((_) => updateTitle());
		_description = _form.querySelector("#description textarea");
		_category = _form.querySelector("#submit select");
		_screenshotUrl = _form.querySelector("#screenshot");
		_preview = shadowRoot.querySelector("#preview");

		// Download latest issue data
		HttpRequest.getString("https://api.github.com/repos/ChildrenOfUr/cou-issues/issues").then((String json) {
			_issuesCache = JSON.decode(json);
		});

		// Set up match clear button
		shadowRoot.querySelector("#clear_match").onClick.listen((Event e) {
			e.preventDefault();
			matchingIssue = -1;
			_form.querySelectorAll("#matches input[type='radio']").forEach((RadioButtonInputElement input) {
				input.checked = false;
			});
		});
	}

	Map<String, dynamic> getIssue(int id) {
		return _issuesCache.where((Map issue) {
			return issue["number"] == id;
		}).toList().first;
	}

	void updateTitle() {
		// Make sure issue data has already been downloaded
		if (_issuesCache == null) {
			return;
		}

		// Clear old data
		shadowRoot.querySelector("#matches").children.clear();

		// Check for matches
		List<Map<String, dynamic>> matches = _issuesCache.where((Map map) {
			return map["title"].toLowerCase().contains(_title.value.toLowerCase());
		}).toList();

		if (_title.value.length > 0 && matches.length > 0) {
			// Create elements if there are matches
			matches.forEach((Map issue) {
				AnchorElement a = new AnchorElement()
					..href = issue["html_url"]
					..target = "_blank"
					..text = issue["title"];

				RadioButtonInputElement selection = new RadioButtonInputElement()
					..name = "matching-issue"
					..onChange.listen((Event e) {
					if ((e.target as RadioButtonInputElement).checked) {
						matchingIssue = issue["number"];
					}
				});

				LIElement li = new LIElement()
					..append(selection)
					..append(a);

				shadowRoot.querySelector("#matches").append(li);
			});
			// Display results
			showMatches = true;
		} else {
			// Hide info box and match list
			showMatches = false;
		}
	}

	void submitForm(Event e) {
		e.preventDefault();

		Map submitMap;
		if (matchingIssue > 0) {
			// Comment on existing issue
			submitMap = {
				"username": username,
				"reply_to_issue": matchingIssue,
				"description": _description.value,
				"log": log,
				"useragent": useragent,
				"image_url": _screenshotUrl.value
			};
		} else {
			// New issue
			submitMap = {
				"username": username,
				"title": _title.value,
				"description": _description.value,
				"category": _category.value,
				"log": log,
				"useragent": useragent,
				"image_url": _screenshotUrl.value
			};
		}

		preview(submitMap);
	}

	void preview(Map data) {
		Element previewContent = _preview.querySelector("#preview-content");
		previewContent.children.clear();

		if (data["reply_to_issue"] == null) {
			// New issue

			// Title
			HeadingElement title = new HeadingElement.h1()
				..text = data["title"];

			previewContent.append(title);
		} else {
			// Existing issue

			// Title
			HeadingElement title = new HeadingElement.h1()
				..text = getIssue(matchingIssue)["title"];

			// Link
			AnchorElement link = new AnchorElement()
				..href = getIssue(matchingIssue)["html_url"]
				..target = "_blank"
				..title = "Your report will be added here"
				..append(title);

			previewContent.append(link);
		}

		// Description
		ParagraphElement description = new ParagraphElement()
			..text = data["description"];

		// Username
		HeadingElement username = new HeadingElement.h2()
			..text = data["username"];

		// Useragent
		HeadingElement useragentTitle = new HeadingElement.h2()
			..text = "User Agent";
		PreElement useragent = new PreElement()
			..text = data["useragent"];

		// Log
		HeadingElement logTitle = new HeadingElement.h2()
			..text = "Log";
		PreElement log = new PreElement()
			..text = data["log"];

		previewContent
			..append(username)
			..append(description)
			..append(useragentTitle)
			..append(useragent)
			..append(logTitle)
			..append(log);

		if (data["image_url"] != "") {
			// Screenshot
			previewContent.append(new ImageElement()
				..src = data["image_url"]);
		}

		// Set up and open the preview window
		_preview
			..querySelector("button[type='submit']").onClick.first.then((_) => send(data))
			..querySelector("button[type='reset']").onClick.first.then((_) => _preview.open = false)
			..open = true;
		// Scroll to the top of the page
		_preview.scrollTop = document.body.scrollTop = shadowRoot.host.scrollTop = 0;
	}

	Future send(Map data) async {
		// Send to server
		String serverAddress = "http://server.childrenofur.com:8181/report/add";
		//await HttpRequest.request(serverAddress, method: "POST", sendData: data);
		print(data);
		transmit("REPORT_SENT", data);
	}
}