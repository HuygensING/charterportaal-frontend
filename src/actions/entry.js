import router from "../router";
import config from "../config";
import {findRelationTypeId} from "./relation-types";
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

//             createRelation(id, relationType, targetId, token, fetchAndDispatch.bind(this, id, dispatch))
let createRelation = function(id, relationType, targetId, token, callback) {
	let {typeId, inverse} = findRelationTypeId(relationType);
	let data = {
		accepted: true,
		"@type": "charterrelation",
		"^typeId": typeId,
		"^typeType": "relationtype",
		"^sourceId": inverse ? targetId : id,
		"^sourceType": "document",
		"^targetId": inverse ? id : targetId,
		"^targetType": "document"
	};
	let options = {
		headers: {...DEFAULT_HEADERS, Authorization: token},
		method: "POST",
		url: config.relationUrl,
		body: JSON.stringify(data)
	};

	xhr(options, function(err, resp, body) {
		if(resp.statusCode > 299) {
			let parsedBody = JSON.parse(body);
			if(parsedBody.message) { alert(parsedBody.message); }
		}
		callback();
	});
}

// deleteRelation(id, relationType, relation, token, fetchAndDispatch.bind(this, id, dispatch))
let deleteRelation = function(id, relationType, relation, token, callback) {
	let {typeId, inverse} = findRelationTypeId(relationType);
	let data = {
		accepted: false,
		"@type": "charterrelation",
		"^typeId": typeId,
		"^typeType": "relationtype",
		"^sourceId": inverse ? relation.id : id,
		"^sourceType": "document",
		"^targetId": inverse ? id : relation.id,
		"^targetType": "document",
		"_id": relation.relationId,
		"^rev": relation.rev
	};
	let options = {
		headers: {...DEFAULT_HEADERS, Authorization: token},
		method: "PUT",
		url: config.relationUrl + "/" + relation.relationId
	};

	options.body = JSON.stringify(data);

	xhr(options, function(err, resp, body) {
		if(resp.statusCode > 299) {
			let parsedBody = JSON.parse(body);
			if(parsedBody.message) { alert(parsedBody.message); }
		}
		callback();
	});
}

let fetchAndDispatch = function(id, dispatch) {
	fetchEntry(id, (respData) => {
		dispatch({
			type: "SELECT_ENTRY",
			data: respData
		});
	});	
}

export function selectEntry(data) {
	return function(dispatch) {
		fetchAndDispatch(data.id, dispatch);
	}
}

export function addRelation(id, relationType, targetId, token) {
	return function(dispatch) {
		createRelation(id, relationType, targetId, token, fetchAndDispatch.bind(this, id, dispatch))
	}
}
export function removeRelation(id, relationType, relation, token) {
	return function(dispatch) {
		deleteRelation(id, relationType, relation, token, fetchAndDispatch.bind(this, id, dispatch))	
	}
}