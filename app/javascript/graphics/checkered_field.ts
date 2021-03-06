import {Coordinately, Sizeable} from "graphics/models";
import {must} from "helpers";

export enum Layer {
    Background, Main//, Space
}

type ClickEventListener = (cell: Coordinately) => void;
type FieldEvent = "click"

class FieldSizes {
    readonly inPX: Sizeable;
    readonly scale: number;
    readonly offset: Sizeable;
    readonly gameOffset: Sizeable;

    constructor(public readonly inRealPX: Sizeable,
                public readonly inCells: Sizeable,
                public readonly cell: Sizeable
    ) {
        this.inPX = Sizeable.Multiply(inCells, cell);
        this.scale = Math.min(inRealPX.height / this.inPX.height, inRealPX.width / this.inPX.width) | 0;
        this.offset = Sizeable.Sum(inRealPX, Sizeable.Multiply(this.inPX, -this.scale));
        this.offset = Sizeable.Round(Sizeable.Multiply(this.offset, 0.5));
        this.gameOffset = Sizeable.Multiply(this.offset, 1 / this.scale);
    }

    static CreateByElement(element: Element, field: Sizeable, cell: Sizeable): FieldSizes {
        let inRealPX = Sizeable.Make(element.clientWidth, element.clientHeight);
        return new FieldSizes(inRealPX, field, cell);
    }
}

class FieldForMouse {
    private readonly field: Array<Array<any>>;

    constructor(private size: FieldSizes) {
        this.field = new Array<Array<any>>(size.inCells.width);
        for (let i = 0; i < size.inCells.width; i++) {
            this.field[i] = new Array<any>();
        }
    }

    addCell(pos: Coordinately, size: Sizeable) {
        if (!this.field[pos.x]) {
            return;
        }
        this.field[pos.x].push(
            {
                size: size,
                y: pos.y,
                start: (pos.y + 1) * this.size.cell.height - size.height,
                end: (pos.y + 1) * this.size.cell.height
            });
        this.field[pos.x].sort((a: any, b: any) => {
            return a.start - b.start
        });
    }

    getCell(real: Sizeable): Coordinately {
        const x = (real.width / this.size.scale / this.size.cell.width) | 0;
        let result = -1;
        const line = this.field[x];
        const y = real.height / this.size.scale;
        if (line)
            line.forEach(
                (value) => {
                    if (value.start < y && y < value.end)
                        result = value.y
                });
        return {
            x: x,
            y: result == -1 ? (y / this.size.cell.height) | 0 : result
        };
    }
}

export class CheckeredField {
    public sizes: FieldSizes;
    private canvases = new Map<Layer, HTMLCanvasElement>();
    private contexts = new Map<Layer, CanvasRenderingContext2D>();
    private clickListeners = new Array<ClickEventListener>();
    private _currentCell = {x: 0, y: 0};
    private sprites: FieldForMouse;

    constructor(
        private mainCanvas: HTMLCanvasElement,
        private backgroundCanvas: HTMLCanvasElement,
    ) {
        this.canvases.set(Layer.Main, mainCanvas);
        this.canvases.set(Layer.Background, backgroundCanvas);
        this.sizes = FieldSizes.CreateByElement(
            must(this.canvases.get(Layer.Main)),
            {width: 1, height: 1},
            {
                width: 16,
                height: 16
            });
        this.sprites = new FieldForMouse(this.sizes);
        mainCanvas.addEventListener('mousemove', (event) => {
            this._currentCell = this.getCurrentCell(event);
        });
        mainCanvas.addEventListener('click', (event) => {
            this._currentCell = this.getCurrentCell(event);
            this.clickListeners.forEach(value => value(this._currentCell));
        });
    }

    get activeCell(): Coordinately {
        // console.log(this._currentCell);
        return this._currentCell;
    }

    static Make(root: HTMLElement) {
        let canvasBack = document.createElement('canvas');
        let canvasMain = document.createElement('canvas');
        root.appendChild(canvasBack);
        root.appendChild(canvasMain);
        return new CheckeredField(canvasMain, canvasBack)
    }

    addEventListener(event: FieldEvent, callback: ClickEventListener) {
        switch (event) {
            case "click":
                this.clickListeners.push(callback);
                break;
            default:
                throw new RangeError(`${event} is not a FieldEvent`)
        }
    }

    getContext(layer: Layer): CanvasRenderingContext2D {
        let context = this.contexts.get(layer);
        if (!context) {
            throw new RangeError(`Incorrect layer: ${layer}`);
        }
        return context;
    }

    resize(field: Sizeable, cell: Sizeable) {
        this.sizes = FieldSizes.CreateByElement(must(this.canvases.get(Layer.Main)), field, cell);
        this.sprites = new FieldForMouse(this.sizes);
        this.canvases.forEach(
            (canvas, layer) => {
                let context = CanvasHelper.getContext(CanvasHelper.setSize(canvas, this.sizes.inRealPX));
                let offset = this.sizes.offset;
                context.translate(offset.width, offset.height);
                context.scale(this.sizes.scale, this.sizes.scale);
                context.imageSmoothingEnabled = false;
                this.contexts.set(layer, context);
            });
    }

    drawSpriteIn(layer: Layer, currentCell: Coordinately,
                 size: Sizeable, draw: (ctx: CanvasRenderingContext2D) => void) {
        let context = this.getContext(layer);
        context.save();
        context.translate(currentCell.x * this.sizes.cell.width,
            (currentCell.y + 1) * this.sizes.cell.height - size.height);
        draw(context);
        context.restore();
        this.sprites.addCell(currentCell, size);
    }

    fillBackground(sprite: ImageBitmap) {
        let background = this.getContext(Layer.Background);
        let pattern = background.createPattern(sprite, 'repeat');
        if (!pattern) {
            throw "Not pattern";
        }
        background.fillStyle = pattern;
        background.fillRect(0, 0, this.sizes.inPX.width, this.sizes.inPX.height);
    }

    clear(layer: Layer) {
        const offsetW = this.sizes.gameOffset.width;
        const offsetH = this.sizes.gameOffset.height;
        this.getContext(layer).clearRect(
            -offsetW / 2 | 0, -offsetH / 2 | 0,
            this.sizes.inPX.width + offsetW, this.sizes.inPX.height + offsetH);
    }

    private getCurrentCell(event: MouseEvent): Coordinately {
        let real = Sizeable.Sum(
            Sizeable.Multiply(this.sizes.offset, -1),
            Sizeable.Make(
                event.offsetX,
                event.offsetY));
        /*return {
            x: (real.width / this.sizes.scale / this.sizes.cell.width) | 0,
            y: (real.height / this.sizes.scale / this.sizes.cell.height) | 0
        };*/
        return this.sprites.getCell(real);
    }
}

module CanvasHelper {
    export function setSize(canvas: HTMLCanvasElement, size: Sizeable) {
        canvas.width = size.width;
        canvas.height = size.height;
        return canvas;
    }

    export function getContext(canvasMain: HTMLCanvasElement): CanvasRenderingContext2D {
        return canvasMain.getContext("2d") as CanvasRenderingContext2D;
    }
}