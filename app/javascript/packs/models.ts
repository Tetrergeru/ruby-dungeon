export class Entity {
    id?: string;
    x: number;
    y: number;
    type: string;
    constructor(raw: any) {
        this.id = raw.id;
        this.x = raw.x;
        this.y = raw.y;
        this.type = raw.name;
    }
}

export class Level {
    constructor(
        public readonly width: number,
        public readonly height: number,
        public readonly floorType: string,
        public readonly entity: Array<Entity>) {
    }
}

function parseLevel(json: string) {
    const raw = JSON.parse(json);
    return new Level(raw.width, raw.height, raw.floor, raw.items.map(x => new Entity(x)))
}

export function getLevel(id: string): Promise<Level> {
    return new Promise(function(resolve, reject)
    {
        const xhr = new XMLHttpRequest();
        xhr.open('GET', `/levels/show/${id}`);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onloadend = () => {
            if (xhr.status === 200) {
                console.log(xhr.responseText);
                return resolve(parseLevel(xhr.responseText))
            }
            reject(xhr.statusText)
        };
        xhr.send();
    });
}