import {Entity, Drawable} from "models";
import {downloadImages} from "resources";
import {CheckeredField, Layer} from "graphics/checkered_field";
import {Coordinately, Sizeable} from "graphics/models";

export function getDrawers(...ids: string[]) {
    return downloadImages()
        .then((collection) => {
            console.log("Images were downloaded!");
            return Promise.all(
                ids.map(
                    id => new Drawer(
                        CheckeredField.Make(document.getElementById(id)), collection)));
        })
        .catch(reason => {
            const err = `Download or create imgs: ${reason}`;
            console.error(err);
            throw err;
        });
}

function drawCell(cell: Sizeable) {
    return (ctx: CanvasRenderingContext2D) => {
        ctx.strokeRect(0, 0, cell.width-1, cell.height-1)
    };
}

type ClickableEventListener = (Entity) => void;

export class Drawer {
    constructor(
        private field: CheckeredField,
        private resources: Map<string, ImageBitmap>) {
        let drawing = () => {
            if(this.drawable) {
                this.field.clear(Layer.Main);
                this.drawable.entity.forEach(entity => {
                    this.drawEntity(entity);
                });
                this.field.drawSpriteIn(
                    Layer.Main, this.field.activeCell, this.field.sizes.cell,
                    drawCell(this.field.sizes.cell));
                let active = this.getEntity(this.field.activeCell);
                if(active && active.id) this.drawEntity(active);
            }
            requestAnimationFrame(drawing);
        };
        requestAnimationFrame(drawing);
    }

    private drawEntity(entity: Entity) {
        const sprite = this.Must(entity.type);
        this.field.drawSpriteIn(
            Layer.Main, entity, sprite,
            (ctx) => ctx.drawImage(sprite, 0, 0));
    }

    private drawable: Drawable;
    setLevel(lvl: Drawable) {
        this.drawable = lvl;
        const cell = this.Must(this.drawable.floorType);
        this.field.resize(this.drawable, cell);
        this.field.fillBackground(cell);
        console.log(this.drawable);
    }

    addEventListener(type: string, callback: ClickableEventListener) {
        this.field.addEventListener('click', cell => {
            let entity = this.getEntity(cell);
            if(entity)
                callback(entity);
        })
    }

    private getEntity(cell: Coordinately) {
        return this.drawable.entity.find(entity => entity.x == cell.x && entity.y == cell.y);
    }

    private Must(resource: string) {
        const floor = this.resources.get(resource);
        if (!floor)
            throw `${resource} not found!`;
        return floor;
    }
}
