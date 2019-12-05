import {Drawable, Entity} from "models";
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
    // cell = Sizeable.Sum(cell, Sizeable.Make(2, 2));
    return (ctx: CanvasRenderingContext2D) => {
        ctx.strokeRect(0, 0, cell.width, cell.height)
    };
}

type ClickableEventListener = (Entity) => void;

export class Drawer {
    private drawable: Drawable;

    constructor(
        private field: CheckeredField,
        private resources: Map<string, ImageBitmap>) {
        let drawing = () => {
            if (this.drawable) {
                this.field.clear(Layer.Main);
                this.drawable.entity.forEach(entity => {
                    this.drawEntity(entity);
                });
                const backSprite = this.Must(this.drawable.borderType);
                for (let i = -1; i <= this.drawable.width; ++i) {
                    this.drawSprite(Layer.Main, {x: i, y: this.drawable.height}, backSprite)
                }
                let active = this.getEntity(this.field.activeCell);
                if (active && active.id) {
                    let sprite = this.Must(active.type);
                    this.field.drawSpriteIn(
                        Layer.Main, this.field.activeCell, sprite,
                        drawCell(sprite));
                    this.drawEntity(active);
                }
            }
            requestAnimationFrame(drawing);
        };
        requestAnimationFrame(drawing);
    }

    private drawEntity(entity: Entity) {
        const sprite = this.Must(entity.type);
        this.drawSprite(Layer.Main, entity, sprite);
    }

    private drawSprite(layer: Layer, coords: Coordinately, sprite: ImageBitmap) {
        this.field.drawSpriteIn(
            layer, coords, sprite,
            (ctx) => ctx.drawImage(sprite, 0, 0));
    }

    private drawRectangle(layer: Layer, start: Coordinately, size: Sizeable, sprite: ImageBitmap) {
        for (let i = 0; i < size.width; ++i)
            for (let j = 0; j < size.height; ++j)
                this.drawSprite(layer, {x: start.x + i, y: start.y + j}, sprite);
    }

    setLevel(lvl: Drawable) {
        if(lvl.equalEnvironments(this.drawable)) {
            this.drawable = lvl;
            console.log("Drawable didn't change")
            return;
        }
        this.drawable = lvl;
        const cell = this.Must(this.drawable.floorType);
        this.field.resize(this.drawable, cell);
        const borderSprite = this.Must(this.drawable.borderType);
        this.drawRectangle(Layer.Background, {x: -1, y: -1}, {width: lvl.width + 2, height: 1}, borderSprite);
        this.drawRectangle(Layer.Background, {x: -1, y: 0}, {width: 1, height: lvl.height}, borderSprite);
        this.drawRectangle(Layer.Background, {x: lvl.width, y: 0}, {width: 1, height: lvl.height}, borderSprite);
        this.field.fillBackground(cell);
        console.log(this.drawable);
    }

    addEventListener(type: string, callback: ClickableEventListener) {
        this.field.addEventListener('click', cell => {
            let entity = this.getEntity(cell);
            if (entity)
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
