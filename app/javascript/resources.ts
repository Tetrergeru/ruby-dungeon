import {fetchJSON} from "http_helpers";
import {must} from "helpers";

interface Texture {
    readonly file: string
}

export function downloadImages() {
    return fetchJSON(`/assets/textures_x32.json`)
        .then(json => {
            const textures = json as Array<Texture>;
            const promises = new Array<Promise<ImageBitmapSource>>();
            const names = new Array<string>();
            for (let key in textures) {
                promises.push(loadImage(must(textures[key]).file));
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
