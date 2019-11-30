import {fetchJSON} from "packs/http_helpers";

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

function parseLevel(raw: any) {
    return new Level(raw.width, raw.height, raw.floor, raw.items.map(x => new Entity(x)))
}

export function getLevel(id: string): Promise<Level> {
    return fetchJSON(`/levels/show/${id}`).then(json => parseLevel(json));
}
