import {Entity, Level} from "packs/models";
import {downloadImages} from "packs/resources";
import {CheckeredField, Layer} from "packs/graphics/checkered_field";
import {Sizeable} from "packs/graphics/models";

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
        ctx.strokeRect(0, 0, cell.width, cell.height)
    };
}

type ClickableEventListener = (Entity) => void;

export class Drawer {
    constructor(
        private field: CheckeredField,
        private resources: Map<string, ImageBitmap>) {
        let drawing = () => {
            if(this.lvl) {
                this.field.clear(Layer.Main);
                this.lvl.entity.forEach(entity => {
                    const sprite = this.Must(entity.type);
                    this.field.drawSpriteIn(
                        Layer.Main, entity, sprite,
                        (ctx) => ctx.drawImage(sprite, 0, 0));
                });
                this.field.drawSpriteIn(
                    Layer.Main, this.field.activeCell, this.field.sizes.cell,
                    drawCell(this.field.sizes.cell));
            }
            requestAnimationFrame(drawing);
        };
        requestAnimationFrame(drawing);
    }

    private lvl: Level;
    setLevel(lvl: Level) {
        this.lvl = lvl;
        const cell = this.Must(this.lvl.floorType);
        this.field.resize(this.lvl, cell);
        this.field.fillBackground(cell);
        console.log(this.lvl);
    }

    addEventListener(type: string, callback: ClickableEventListener) {
        this.field.addEventListener('click', cell => {
            let entity = this.lvl.entity.find(entity => entity.x == cell.x && entity.y == cell.y);
            if(entity)
                callback(entity);
        })
    }

    private Must(resource: string) {
        const floor = this.resources.get(resource);
        if (!floor)
            throw `${resource} not found!`;
        return floor;
    }
}
