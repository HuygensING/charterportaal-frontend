import config from "../config";
import xhr from "xhr";

const DEFAULT_HEADERS = {
	"Accept": "application/json",
	"Content-type": "application/json",
	"VRE_ID": config.vreId
}

let relationTypes = null

export function fetchRelationTypes(callback) {
	let options = {
		headers: DEFAULT_HEADERS,
		url: config.relationTypesUrl
	};

	xhr(options, function(err, resp, body) {
		relationTypes = JSON.parse(body);
		callback();
	});
}

export function findRelationTypeId(name) {
	for(let i in relationTypes) {
		if(relationTypes[i].regularName === name) {
			return {typeId: relationTypes[i]._id, inverse: false}
		} else if(relationTypes[i].inverseName === name) {
			return {typeId: relationTypes[i]._id, inverse: true}
		}
	}
	return null;
}