/** 
 * Generate an array with the given range of numbers. `end` is not inclusive.
 */
export function range(start: number, end:number, step = 1) {
    return Array.from({length: Math.ceil((end - start) / step)}, (_, i) => start + i * step)
}
