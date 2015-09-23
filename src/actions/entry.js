import router from "../router";
import config from "../config";
import xhr from "xhr";

let fetchEntry = function(id, callback) {
	let options = {
		headers: {
			"Accept": "application/json",
			"VRE_ID": config.vreId
		},
		url: `${config.entryUrl}/${id}`
	};
	let xhrDone = function(err, resp, body) {
		callback(JSON.parse(body))
	}
	xhr(options, xhrDone);
}


export function selectEntry(data) {
	return function(dispatch) {
		fetchEntry(data.id, (respData) => {
			router.navigate(data.id + "/edit");
			dispatch({
				type: "SELECT_ENTRY",
				data: respData
			});
		});
	}
}