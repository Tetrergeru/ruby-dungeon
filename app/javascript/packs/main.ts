import {Drawer, getResources} from "packs/graphics";
import {Level, getLevel} from "packs/models";

Promise.all<Drawer, Level>([
    getResources(),
    getLevel(window.location.pathname.substr(1))]
    )
    .then(objects => {
        console.log("All were downloaded!");
        objects[0].drawLevel(objects[1]);
    })
    .catch(reason => {
        const err = `Draw level: ${reason}`;
        console.error(err);
        alert(err);
    });

console.log("Start!");
{
    // let camera = new Camera(canvas);
    let timerTick: number;
    const start = () => {
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

    };
    start()
    let drawing = () => {
        requestAnimationFrame(drawing);
    }
    requestAnimationFrame(drawing);
}

