export function receiveUser(data) {
	return function(dispatch) {
		dispatch({
			type: "USER_RECEIVE",
			data: data
		})
	}
}