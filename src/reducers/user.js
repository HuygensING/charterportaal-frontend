let initialState = {
	displayName: null,
	email: null,
	token: null
};


export default function(state=initialState, action) {
	switch (action.type) {
		case "USER_RECEIVE":
			return {...state, ...action.data};
		default:
			return state;
	}
}