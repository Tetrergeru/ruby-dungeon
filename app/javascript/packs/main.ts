class Entity {
    id?: string;
    x: number;
    y: number;
    type: string;
    constructor(raw: any) {
        this.id = raw.id;
        this.x = raw.x;
        this.y = raw.y;
        this.type = raw.type;
    }
}

class Level {
    constructor(
        public readonly width: number,
        public readonly height: number,
        public readonly floorType: string,
        public readonly entity: Array<Entity>) {
        
    }
}

class Drawer {
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
        let background = getContext(this.backgroundCanvas)
        let main = getContext(this.mainCanvas)
        main.imageSmoothingEnabled = false;
        background.imageSmoothingEnabled = false;
        let pattern = background.createPattern(cell, 'repeat')
        if(!pattern)
            throw "Not pattern"
        background.rect(0, 0, lvlWidth, lvlHeight);
        background.fillStyle = pattern;
        background.fill();
        main.lineWidth = 0.4 
        // for(let i = 0; i<lvl.width; i++) {
        //     for(let j = 0; j<lvl.height; j++) {
        //         main.strokeRect(i*cell.width, j*cell.height, cell.width, cell.height)
        //     }
        // }
        lvl.entity.forEach(entity => {
            main.save();
            const sprite = this.Must(entity.type);
            main.drawImage(
                sprite,
                entity.x*cell.width-sprite.width, entity.y*cell.height-sprite.height)//,
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
		var img = new Image();
		img.onload = function()
		{
			return resolve(img);
		}
		img.onerror = function()
		{
			return reject(name);
		}
		img.src = `/assets/${name}.png`;
	});
}

let imgNames = [
    'chest',
    'floor',
    'monster',
    'monster2',
    'wall'
    ];
Promise.all(imgNames.map(loadImage))
    .then((imgs: ImageBitmapSource[]) => {
        return Promise.all(imgs.map(img => createImageBitmap(img)));
    })
    .then((bitmaps: ImageBitmap[]) => {
        let collectionImgs = new Map<string, ImageBitmap>()
        bitmaps.forEach((bitmap, i) => collectionImgs.set(imgNames[i], bitmap))
        return collectionImgs
    })
    .catch(reason => {
        const err = `Downlad or create imgs: ${reason}`;
        console.error(err)
        throw err;
    })
    .then(collectionImgs => {
        console.log("Images were downloaded!");
        let level = new Level(40, 10, "floor", [
            new Entity({x:2, y:2, type: "chest"}),
            new Entity({x:2, y:3, type: "chest"}),
            new Entity({x:1, y:1, type: "monster2"}),
            new Entity({x:3, y:3, type: "monster2"}),
            new Entity({x:4, y:3, type: "monster"}),
            new Entity({x:3, y:4, type: "monster2"}),
            new Entity({x:6, y:3, type: "wall"}),
            new Entity({x:7, y:4, type: "wall"}),
            ])
        let canvasBack = document.getElementById('background') as HTMLCanvasElement;
        let canvasMain = document.getElementById('main') as HTMLCanvasElement;
        let drawer = new Drawer(canvasMain, canvasBack, collectionImgs);
        drawer.drawLevel(level);
    })
    .catch(reason => {
        const err = `Drawing: ${reason}`;
        console.error(err)
    });

console.log("Start!")
{
    // let camera = new Camera(canvas);
    let timerTick: number;
    function start() {
        try {
            clearInterval(timerTick)
        } catch (e) {
            console.log(e);
        }

        let tick = (dt: number) => {
        };
        let prev_time = Date.now();
        timerTick = setInterval(() => {
            let time = Date.now();
            tick(time - prev_time);
            prev_time = time;
        })
        
    }
    start()
    let drawing = () => {
        requestAnimationFrame(drawing);
    }
    requestAnimationFrame(drawing);
}

function getContext(canvasMain: HTMLCanvasElement): CanvasRenderingContext2D {
    return canvasMain.getContext("2d") as CanvasRenderingContext2D;
}
