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

export class Drawable {
    constructor(
        public readonly width: number,
        public readonly height: number,
        public readonly floorType: string,
        public readonly entity: Array<Entity>) {
        entity.sort((a, b) => a.y - b.y)
    }
}

function parseDrawable(raw: any) {
    return new Drawable(raw.width, raw.height, raw.floor, raw.items.map(x => new Entity(x)))
}

export function getDrawableField(id: string): Promise<Drawable> {
    return fetchJSON(`/game/${id}`).then(json => parseDrawable(json));
}
