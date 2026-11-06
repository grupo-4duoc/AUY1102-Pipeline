import { DateValueObject } from '../../../../../src/value-object/primitives/date-value-object';

export default class BirthDate extends DateValueObject {
  constructor(value: string) {
    super(value);
  }

  protected throwErrorForInvalidDate(value: string): void {
    throw new Error(`Fecha invalida: ${value}`);
  }
}
