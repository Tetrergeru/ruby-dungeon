export interface Sizeable {
    readonly width: number
    readonly height: number
}

export module Sizeable {
    export function Multiply(a: Sizeable, b: Sizeable | number): Sizeable {
        if (typeof b === 'number') {
            b = {width: b, height: b}
        }
        return {width: a.width * b.width, height: a.height * b.height};
    }

    export function Sum(a: Sizeable, b: Sizeable): Sizeable {
        return {width: a.width + b.width, height: a.height + b.height};
    }

    export function Make(width: number, height: number): Sizeable {
        return {width: width, height: height};
    }

    export function Ratio(a: Sizeable) {
        return a.width / a.height;
    }

    export function Round(a: Sizeable) {
        return {width: a.width | 0, height: a.height | 0};
    }
}

export interface Coordinately {
    readonly x: number
    readonly y: number
}