import {Coordinately, Sizeable} from "packs/graphics/models";

export enum Layer {
    Background, Main
}

type ClickEventListener = (cell: Coordinately) => void;
type FieldEvent = "click"
export class CheckeredField {
    private canvases = new Map<Layer, HTMLCanvasElement>();
    private contexts = new Map<Layer, CanvasRenderingContext2D>();
    private clickListeners = new Array<ClickEventListener>();
    addEventListener(event: FieldEvent, callback: ClickEventListener) {
        switch (event) {
            case "click":
                this.clickListeners.push(callback);
                break;
            default:
                throw new RangeError(`${event} is not a FieldEvent`)
        }
    }
    public sizes: {
        cell: Sizeable
        inPX: Sizeable
        inCells: Sizeable
    };
    private _currentCell = {x:0, y:0};
    get activeCell(): Coordinately {
        // console.log(this._currentCell);
        return this._currentCell;
    }

    getContext(layer: Layer): CanvasRenderingContext2D {
        let context = this.contexts.get(layer);
        if (!context) {
            throw new RangeError(`Incorrect layer: ${layer}`);
        }
        return context;
    }

    constructor(
        private mainCanvas: HTMLCanvasElement,
        private backgroundCanvas: HTMLCanvasElement,
    ) {
        this.canvases.set(Layer.Main, mainCanvas);
        this.canvases.set(Layer.Background, backgroundCanvas);
        mainCanvas.addEventListener('mousemove', (event) => {
            this._currentCell = this.getCurrentCell(event, mainCanvas);
        });
        mainCanvas.addEventListener('click', (event) => {
            this._currentCell = this.getCurrentCell(event, mainCanvas);
            this.clickListeners.forEach(value => value(this._currentCell));
        });
        this.canvases.forEach(
            (canvas, layer) =>
                this.contexts.set(layer, CanvasHelper.getContext(canvas)));
    }

    private getCurrentCell(event: MouseEvent, canvas: HTMLElement) {
        return {
            x: (this.sizes.inPX.width * event.offsetX / canvas.clientWidth) / this.sizes.cell.width | 0,
            y: (this.sizes.inPX.height * event.offsetY / canvas.clientHeight) / this.sizes.cell.height | 0
        };
    }

    static Make(root: HTMLElement) {
        let canvasBack = document.createElement('canvas');
        let canvasMain = document.createElement('canvas');
        root.appendChild(canvasBack);
        root.appendChild(canvasMain);
        return new CheckeredField(canvasMain, canvasBack)
    }

    resize(field: Sizeable, cell: Sizeable) {
        this.sizes = {
            inCells: field,
            cell: cell,
            inPX: Sizeable.Multiply(field, cell)
        };
        this.canvases.forEach(
            (canvas, layer) => {
                this.contexts.set(layer,
                    CanvasHelper.getContext(CanvasHelper.setSize(canvas, this.sizes.inPX)));
            });
    }

    drawSpriteIn(layer: Layer, currentCell: Coordinately,
                 size: Sizeable, draw: (CanvasRenderingContext2D) => void) {
        let context = this.getContext(layer);
        context.save();
        context.translate(currentCell.x * this.sizes.cell.width,
            (currentCell.y + 1) * this.sizes.cell.height - size.height);
        draw(context);
        context.restore();
    }

    fillBackground(sprite: ImageBitmap) {
        let background = this.getContext(Layer.Background);
        let pattern = background.createPattern(sprite, 'repeat');
        if (!pattern)
            throw "Not pattern";
        background.rect(0, 0, this.sizes.inPX.width, this.sizes.inPX.height);
        background.fillStyle = pattern;
        background.fill();
    }

    clear(layer: Layer) {
        this.getContext(layer).clearRect(0, 0, this.sizes.inPX.width, this.sizes.inPX.height);
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