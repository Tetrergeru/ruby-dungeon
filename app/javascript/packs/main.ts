import {Drawer, getDrawers} from "packs/graphics/drawer";
import {Level, getLevel, Entity} from "packs/models";

Promise.all<Drawer[], Level>([
    getDrawers('level-field', 'chest-field'),
    getLevel(window.location.pathname.substr(1))]
    )
    .then(objects => {
        console.log("All were downloaded!");
        let levelField = objects[0][0];
        let chestField = objects[0][1];
        levelField.addEventListener('select', (entity: Entity) => {
            console.log(entity);
            switch (entity.type) {
                case 'chest':
                    getLevel(`${window.location.pathname.substr(1)}/${entity.id}`)
                        .then(chest => chestField.setLevel(chest));
            }
        });
        levelField.setLevel(objects[1]);
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
}

