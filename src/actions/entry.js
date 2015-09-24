import router from "../router";
import config from "../config";
import xhr from "xhr";

const DEFAULT_HEADERS = {
	"Accept": "application/json",
	"Content-type": "application/json",
	"VRE_ID": config.vreId
}

let fetchEntry = function(id, callback) {
	let options = {
		headers: DEFAULT_HEADERS,
		url: `${config.entryUrl}/${id}`
	};
	let xhrDone = function(err, resp, body) {
		callback(JSON.parse(body))
	}
	xhr(options, xhrDone);
}

let findRelationType = function(name, callback) {
	let options = {
		headers: DEFAULT_HEADERS,
		url: config.relationTypesUrl
	};

	xhr(options, function(err, resp, body) {
		let data = JSON.parse(body);
		callback(data.find((relType) => relType.regularName === name)._id);
	});
 }

let addIsCopyOf = function(id, targetId, token, callback) {
	findRelationType("isCopiedBy", function(typeId) {

		let data = {
			accepted: true,
			"@type": "charterrelation",
			"^typeId": typeId,
			"^sourceId": id,
			"^sourceType": "document",
			"^targetId": targetId,
			"^targetType": "document"
		};
		let options = {
			body: JSON.stringify(data),
			headers: {...DEFAULT_HEADERS, Authorization: token},
			method: "POST",
			url: config.relationUrl
		};
		console.log("after findRelationType", JSON.stringify(data));
		xhr(options, function(err, resp, body) {
			console.log(err);
			console.log(resp);
			console.log(JSON.parse(body));
		});
	});
}

export function selectEntry(data) {
	return function(dispatch) {
		fetchEntry(data.id, (respData) => {
			dispatch({
				type: "SELECT_ENTRY",
				data: respData
			});
		});
	}
}

export function addIsCopyOfRelation(id, targetId, token) {
	return function(dispatch) {
		addIsCopyOf(id, targetId, token);
	}
}