export interface Sizeable {
    readonly width: number
    readonly height: number
}

export module Sizeable {
    export function Multiply(a: Sizeable, b: Sizeable): Sizeable {
        return {width: a.width*b.width, height: a.height*b.height};
    }
}

export interface Coordinately {
    readonly x: number
    readonly y: number
}