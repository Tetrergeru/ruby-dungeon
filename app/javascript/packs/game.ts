import {Drawer, getDrawers} from "graphics/drawer";
import {Drawable, getDrawableField, Entity} from "models";

Promise.all<Drawer[], Drawable>([
    getDrawers('level-field'),
    getDrawableField('')]
)
    .then(objects => {
        console.log("All were downloaded!");
        let levelField = objects[0][0];
        levelField.addEventListener('select', (entity: Entity) => {
            console.log(entity);
            if (entity.id) {
                getDrawableField(`${entity.id}`)
                    .then(drawable => levelField.setLevel(drawable));

            }
        });
        levelField.setLevel(objects[1]);
        setInterval(() => {
            getDrawableField(``)
                .then(drawable => levelField.setLevel(drawable));
        }, 1000)

    })
    .catch(reason => {
        const err = `Draw level: ${reason}`;
        console.error(err);
        alert(err);
    });
