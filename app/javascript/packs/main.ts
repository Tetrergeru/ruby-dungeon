import {Drawer, getDrawers} from "packs/graphics/drawer";
import {Drawable, getDrawableField, Entity} from "packs/models";

Promise.all<Drawer[], Drawable>([
    getDrawers('level-field', 'chest-field'),
    getDrawableField(window.location.pathname.substr(1))]
    )
    .then(objects => {
        console.log("All were downloaded!");
        let levelField = objects[0][0];
        let chestField = objects[0][1];
        levelField.addEventListener('select', (entity: Entity) => {
            console.log(entity);
            switch (entity.type) {
                case 'chest':
                    getDrawableField(`${window.location.pathname.substr(1)}/${entity.id}`)
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
