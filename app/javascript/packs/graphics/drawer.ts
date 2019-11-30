import {Level} from "packs/models";
import {downloadImages} from "packs/resources";
import {CheckeredField, Layer} from "packs/graphics/checkered_field";
import {Sizeable} from "packs/graphics/models";

export function getDrawer() {
    return downloadImages()
        .then((collection) => {
            console.log("Images were downloaded!");
            return new Drawer(CheckeredField.Make(document.getElementById('level-field')), collection);
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

export class Drawer {
    constructor(
        private field: CheckeredField,
        private resources: Map<string, ImageBitmap>) {
    }

    drawLevel(lvl: Level) {
        const cell = this.Must(lvl.floorType);
        this.field.resize(lvl, cell);
        this.field.fillBackground(cell);
        console.log(lvl);
        let drawing = () => {
            this.field.clear(Layer.Main);
            lvl.entity.forEach(entity => {
                const sprite = this.Must(entity.type);
                this.field.drawSpriteIn(
                    Layer.Main, entity, sprite,
                    (ctx) => ctx.drawImage(sprite, 0, 0));
            });
            this.field.drawSpriteIn(
                Layer.Main, this.field.activeCell, this.field.sizes.cell,
                drawCell(this.field.sizes.cell));
            requestAnimationFrame(drawing);
        };
        requestAnimationFrame(drawing);
    }

    private Must(resource: string) {
        const floor = this.resources.get(resource);
        if (!floor)
            throw `${resource} not found!`;
        return floor;
    }
}
