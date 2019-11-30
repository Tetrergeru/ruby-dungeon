export function fetchJSON(url: RequestInfo) {
    return fetch(url,
        {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(response => response.json())
}