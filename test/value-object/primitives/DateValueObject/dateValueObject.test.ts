import BirthDate from './__mocks__/BirthDate';

describe('DateValueObject', () => {
  const fechaValida = '2024-05-10T12:00:00.000Z';

  it('debe crearse correctamente con una fecha valida', () => {
    const fecha = new BirthDate(fechaValida);
    expect(fecha).toBeInstanceOf(BirthDate);
    expect(fecha.value).toBe(new Date(fechaValida).toISOString());
  });

  it('debe lanzar error cuando se pasa una fecha invalida', () => {
    expect(() => new BirthDate('fecha-falsa')).toThrow('Fecha invalida: fecha-falsa');
  });

  it('debe comparar si una fecha es anterior a otra', () => {
    const fecha1 = new BirthDate('2024-01-01T00:00:00.000Z');
    expect(fecha1.isBeforeThisDate(fechaValida)).toBe(true);
  });

  it('debe comparar si una fecha es posterior a otra', () => {
    const fecha2 = new BirthDate('2024-12-31T00:00:00.000Z');
    expect(fecha2.isAfterThisDate(fechaValida)).toBe(true);
  });

  it('debe validar si una fecha esta entre dos fechas', () => {
    const fechaInicio = '2024-01-01T00:00:00.000Z';
    const fechaFin = '2024-12-31T00:00:00.000Z';
    const fecha = new BirthDate(fechaValida);
    expect(fecha.isBetweenTheDates(fechaInicio, fechaFin)).toBe(true);
  });
});
