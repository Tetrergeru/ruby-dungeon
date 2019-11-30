import {Level} from "packs/models";
import {fetchJSON} from "packs/http_helpers";

interface Texture {
    readonly file: string
}

function downloadImages() {
    return fetchJSON(`/assets/textures.json`)
        .then(json => {
            const textures = json as Map<string, Texture>;
            const promises = new Array<Promise<ImageBitmapSource>>();
            const names = new Array<string>();
            for (let key in textures) {
                promises.push(loadImage(textures[key].file));
                names.push(key)
            }
            return Promise.all(promises)
                .then((imgs: ImageBitmapSource[]) => {
                    return Promise.all(
                        imgs.map(img => createImageBitmap(img)));
                })
                .then((bitmaps) => {
                    let collectionImgs = new Map<string, ImageBitmap>();
                    bitmaps.forEach((bitmap, i) => collectionImgs.set(names[i], bitmap));
                    return collectionImgs
                });
        });
}

export function getDrawer() {
    return downloadImages()
        .then((collection) => {
            console.log("Images were downloaded!");
            let canvasBack = document.getElementById('background') as HTMLCanvasElement;
            let canvasMain = document.getElementById('main') as HTMLCanvasElement;
            return new Drawer(canvasMain, canvasBack, collection);
        })
        .catch(reason => {
            const err = `Download or create imgs: ${reason}`;
            console.error(err);
            throw err;
        });
}

export class Drawer {
    constructor(
        private mainCanvas: HTMLCanvasElement,
        private backgroundCanvas: HTMLCanvasElement,
        private resources: Map<string, ImageBitmap>) {
    }
    drawLevel(lvl: Level) {
        const cell = this.Must(lvl.floorType);
        const lvlWidth = cell.width * lvl.width;
        const lvlHeight = cell.height * lvl.height;
        this.mainCanvas.width = lvlWidth;
        this.mainCanvas.height = lvlHeight;
        this.backgroundCanvas.width = lvlWidth;
        this.backgroundCanvas.height = lvlHeight;
        let background = getContext(this.backgroundCanvas);
        let main = getContext(this.mainCanvas);
        main.imageSmoothingEnabled = false;
        background.imageSmoothingEnabled = false;
        let pattern = background.createPattern(cell, 'repeat');
        if(!pattern)
            throw "Not pattern";
        background.rect(0, 0, lvlWidth, lvlHeight);
        background.fillStyle = pattern;
        background.fill();
        main.lineWidth = 0.4;
        // for(let i = 0; i<lvl.width; i++) {
        //     for(let j = 0; j<lvl.height; j++) {
        //         main.strokeRect(i*cell.width, j*cell.height, cell.width, cell.height)
        //     }
        // }
        console.log(lvl);
        lvl.entity.forEach(entity => {
            main.save();
            const sprite = this.Must(entity.type);
            main.drawImage(
                sprite,
                entity.x*cell.width, (entity.y+1)*cell.height-sprite.height);//,
            // cell.width, cell.height)
            main.restore();
        })
    }
    private Must(resource: string) {
        const floor = this.resources.get(resource);
        if (!floor)
            throw `${resource} not found!`;
        return floor;
    }
}

function loadImage(name: string): Promise<ImageBitmapSource>
{
    return new Promise(function(resolve, reject)
    {
        let img = new Image();
        img.onload = function()
        {
            return resolve(img);
        };
        img.onerror = function()
        {
            return reject(name);
        };
        img.src = `/assets/${name}`;
    });
}

function getContext(canvasMain: HTMLCanvasElement): CanvasRenderingContext2D {
    return canvasMain.getContext("2d") as CanvasRenderingContext2D;
}