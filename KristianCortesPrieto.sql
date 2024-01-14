/* -------------------------------------------------------------------------------------------
Nombre del autor: Kristian Sthefan Cortes Prieto
Nombre de la base de datos: ArteVidaCultural
 ---------------------------------------------------------------------------------------------------*/

DROP DATABASE IF EXISTS ArteVidaCultural; -- se borra la base de datos si existe

CREATE DATABASE ArteVidaCultural; -- se crea la base de datos

USE ArteVidaCultural; -- se utiliza la base de datos que se acaba de crear

/* ------------------------------------------------------------------------------------------------ Definición de la estructura de la base de datos --------------------------------------------------------------------------------------------------*/

CREATE TABLE PERSONA (
    persona_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    primer_apellido VARCHAR(255) NOT NULL,
    segundo_apellido VARCHAR(255),
    email VARCHAR(255),
    cache DECIMAL(10, 2),
    biografia TEXT
);

CREATE TABLE TELEFONO (
    telefono_id INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(15) NOT NULL,
    fk_persona_id INT NOT NULL,
    FOREIGN KEY (fk_persona_id) REFERENCES PERSONA (persona_id)
);

CREATE TABLE ACTIVIDAD (
    actividad_id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(255) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE UBICACION (
    ubicacion_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    ciudad_pueblo VARCHAR(255) NOT NULL,
    aforo INT NOT NULL,
    precio_alquiler DECIMAL(10, 2) NOT NULL,
    caracteristicas TEXT
);

CREATE TABLE EVENTO (
    evento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    precio_entrada DECIMAL(10, 2) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    descripcion TEXT,
    fk_actividad_id INT NOT NULL,
    fk_ubicacion_id INT NOT NULL,
    FOREIGN KEY (fk_actividad_id) REFERENCES ACTIVIDAD (actividad_id),
    FOREIGN KEY (fk_ubicacion_id) REFERENCES UBICACION (ubicacion_id)
);

CREATE TABLE PARTICIPACION (
    participacion_id INT AUTO_INCREMENT PRIMARY KEY,
    asistencia BOOLEAN,
    evaluacion TINYINT,
    CHECK (evaluacion >= 1 AND evaluacion <= 5),-- revisa que este entre 1 y 5
    rol VARCHAR(255),
    fk_persona_id INT NOT NULL,
    fk_evento_id INT NOT NULL,
    FOREIGN KEY (fk_evento_id) REFERENCES EVENTO (evento_id),
    FOREIGN KEY (fk_persona_id) REFERENCES PERSONA (persona_id)
);

CREATE TABLE ERROR (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensaje VARCHAR(255),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*------------------------------------------------------------------------------------------------------
Trigger
Inserción de datos -------------------------------------------------------------------------------------------------------*/

DELIMITER //
CREATE TRIGGER VALIDACION_PARTICIPACION BEFORE INSERT ON PARTICIPACION
FOR EACH ROW
BEGIN
    DECLARE actor_count INT;
    DECLARE espectador_count INT;
    DECLARE error_message VARCHAR(255);
    IF NEW.rol IS NOT NULL THEN -- aquí se encarga de preguntar si la participación es de un artista
        SET actor_count = (SELECT COUNT(*) FROM PARTICIPACION
                          WHERE fk_persona_id = NEW.fk_persona_id
                          AND fk_evento_id = NEW.fk_evento_id
                          AND rol IS NOT NULL); -- realiza la consulta si ya este artista esta registrado en el evento
        IF actor_count > 0 THEN -- si ya existe procede a añadir el error en la tabla error
            SET error_message = CONCAT('No se permite ser actor y espectador en el mismo evento. Valores: fk_persona_id=', NEW.fk_persona_id, ', fk_evento_id=', NEW.fk_evento_id, ', rol=', NEW.rol);
            INSERT INTO ERROR (mensaje) VALUES (error_message);
        END IF;
    END IF;
    IF NEW.rol IS NULL THEN -- aquí se encarga de preguntar si la participación es de un espectador
        SET espectador_count = (SELECT COUNT(*) FROM PARTICIPACION
                               WHERE fk_persona_id = NEW.fk_persona_id
                               AND fk_evento_id = NEW.fk_evento_id
                               AND rol IS NULL); -- realiza la consulta si ya este espectador esta registrado en el evento
        IF espectador_count > 0 THEN -- si ya existe procede a añadir el error en la tabla error
            SET error_message = CONCAT('No se permite ser espectador y actor en el mismo evento. Valores: fk_persona_id=', NEW.fk_persona_id, ', fk_evento_id=', NEW.fk_evento_id);
            INSERT INTO ERROR (mensaje) VALUES (error_message);
        END IF;
    END IF;
END;
//
DELIMITER ;




INSERT INTO PERSONA (nombre, primer_apellido, segundo_apellido, email, cache, biografia)
VALUES
('Juan', 'Pérez', 'López', 'juan.perez@example.com', 1000.00, 'Juan Pérez López es un artista plástico español. Se especializa en pintura y escultura.'),
('María', 'García', 'Martínez', 'maria.garcia@example.com', 2000.00, 'María García Martínez es una actriz española. Es conocida por sus papeles en las películas "La vida es bella" y "El secreto de sus ojos".'),
('Pedro', 'González', 'Pérez', 'pedro.gonzalez@example.com', 3000.00, 'Pedro González Pérez es un músico español. Es líder de la banda de rock "Los Rodríguez".'),
('Ana', 'Sánchez', 'López', 'ana.sanchez@example.com', 4000.00, 'Ana Sánchez López es una escritora española. Es autora de varios libros de éxito, entre ellos "La casa de las palabras" y "El jardín de los secretos".'),
('Luis', 'Fernández', 'Martínez', 'luis.fernandez@example.com', 5000.00, 'Luis Fernández Martínez es un director de cine español. Ha dirigido varias películas premiadas, entre ellas "La última película" y "La vida en un hilo".'),
('Carmen', 'González', 'Pérez', 'carmen.gonzalez@example.com', 6000.00, 'Carmen González Pérez es una bailarina española. Es miembro del Ballet Nacional de España.'),
('Jorge', 'García', 'López', 'jorge.garcia@example.com', 7000.00, 'Jorge García López es un actor de teatro español. Ha participado en varias obras de teatro clásicas y modernas.'),
('Isabel', 'Sánchez', 'Martínez', 'isabel.sanchez@example.com', 8000.00, 'Isabel Sánchez Martínez es una cantante española. Ha publicado varios álbumes de éxito.'),
('Pablo', 'Fernández', 'López', 'pablo.fernandez@example.com', 9000.00, 'Pablo Fernández López es un pintor español. Su obra se centra en la abstracción.'),
('Teresa', 'González', 'Pérez', 'teresa.gonzalez@example.com', 10000.00, 'Teresa González Pérez es una escultora española. Su obra se centra en la figura humana.'),
('Antonio', 'García', 'López', 'antonio.garcia@example.com', 11000.00, 'Antonio García López es un escritor español. Es autor de varios libros de cuentos y novelas.'),
('Marta', 'Sánchez', 'Martínez', 'marta.sanchez@example.com', 12000.00, 'Marta Sánchez Martínez es una directora de teatro española. Ha dirigido varias obras de teatro contemporáneas.'),
('Carlos', 'Fernández', 'López', 'carlos.fernandez@example.com', 13000.00, 'Carlos Fernández López es un actor de cine español. Ha participado en varias películas de éxito.'),
('Laura', 'González', 'Pérez', 'laura.gonzalez@example.com', 14000.00, 'Laura González Pérez es una bailarina de ballet español. Es miembro de una compañía de ballet independiente.'),
('David', 'García', 'López', 'david.garcia@example.com', 15000.00, 'David García López es un músico español. Es miembro de una banda de rock indie.'),
('Julia', 'Sánchez', 'Martínez', 'julia.sanchez@example.com', 1600.00, 'Actriz de telenovela.');

INSERT INTO TELEFONO (numero, fk_persona_id)
VALUES
('666 123 456', 1),
('91 234 5678', 2),
('654 789 012', 3),
('666 123 457', 4),
('91 234 5679', 5),
('654 789 013', 6),
('666 123 458', 7),
('654 789 014', 9),
('666 123 459', 10),
('91 234 5681', 11),
('654 789 015', 12),
('666 123 460', 13),
('91 234 5682', 14),
('654 789 016', 15),
('666 123 461', 16),
('91 234 5683', 1),
('654 789 017', 2),
('91 234 5684', 4),
('654 789 018', 5),
('91 234 5685', 7),
('666 123 464', 9),
('654 789 020', 11),
('666 123 465', 12),
('654 789 021', 14),
('666 123 466', 15),
('91 234 5688', 16),
('654 789 022', 1),
('666 123 467', 2),
('91 234 5689', 3);

INSERT INTO ACTIVIDAD (tipo, descripcion)
VALUES
    ('Concierto', 'Actividad musical en vivo con varios artistas.'),
    ('Exposición', 'Exhibición de obras de arte y otros objetos culturales.'),
    ('Obra de Teatro', 'Representación teatral en vivo.'),
    ('Conferencia', 'Presentación de charlas o discursos informativos.');

INSERT INTO UBICACION (nombre, direccion, ciudad_pueblo, aforo, precio_alquiler, caracteristicas)
VALUES
('Museo del Prado', 'Calle del Prado, 8', 'Madrid', 25000, 1000.00, 'Museo de arte con una colección de más de 7.000 obras de arte, que incluyen obras de Velázquez, Goya, El Greco y otros artistas españoles e internacionales.'),
('Teatro Real', 'Plaza de Isabel II, 2', 'Madrid', 2000, 2000.00, 'Principal ópera de España. Ofrece una amplia programación de ópera, ballet y música clásica.'),
('Cine Capitol', 'Gran Vía, 41', 'Madrid', 1000, 100.00, 'Cine histórico de Madrid. Fue construido en 1920 y es uno de los cines más antiguos de España.'),
('Parque del Retiro', 'Paseo de la Infanta Isabel, s/n', 'Madrid', 120000, 0.00, 'Uno de los parques más grandes de Madrid. Es un popular lugar de ocio para los madrileños y visitantes.'),
('Plaza Mayor', 'Plaza Mayor, 1', 'Madrid', 20000, 0.00, 'Plaza histórica de Madrid. Es un lugar popular para realizar eventos, como conciertos y festivales.'),
('Palacio Real', 'Calle de Bailén, s/n', 'Madrid', 1500, 0.00, 'Residencia oficial del rey de España. Está abierto al público para visitas.'),
('Mercado de San Miguel', 'Plaza de San Miguel, s/n', 'Madrid', 1000, 0.00, 'Mercado gastronómico ubicado en el centro de Madrid. Ofrece una amplia variedad de productos frescos, así como restaurantes y bares.'),
('Glorieta de Cibeles', 'Plaza de Cibeles, s/n', 'Madrid', 0, 0.00, 'Plaza ubicada en el centro de Madrid. Es un lugar popular para celebrar los éxitos del Real Madrid, el equipo de fútbol de la ciudad.'),
('Puente de Segovia', 'Calle del Puente de Segovia, s/n', 'Madrid', 0, 0.00, 'Puente romano que cruza el río Manzanares. Es uno de los puentes más antiguos de Madrid.');


INSERT INTO EVENTO (nombre, precio_entrada, fecha, hora, descripcion, fk_actividad_id, fk_ubicacion_id)
VALUES 
('Concierto de Rock', 15.00, '2023-11-01', '19:30:00', 'Un emocionante concierto de rock con bandas locales.', 1, 3),
('Exposición de Arte Moderno', 5.00, '2023-11-05', '11:00:00', 'Descubre obras de arte moderno de artistas contemporáneos.', 2, 1),
('Ópera en Vivo', 25.00, '2023-11-10', '20:00:00', 'Una magnífica presentación de ópera en el Teatro Real.', 3, 2),
('Conferencia de Arte', 0.00, '2023-11-15', '15:00:00', 'Una charla informativa sobre el arte contemporáneo.', 4, 7),
('Cine al Aire Libre', 10.00, '2023-11-20', '21:00:00', 'Proyección de una película clásica en el Parque del Retiro.', 3, 4),
('Festival de Música Indie', 20.00, '2023-11-25', '17:00:00', 'Disfruta de bandas de música indie en la Plaza Mayor.', 1, 5),
('Recorrido Histórico', 5.00, '2023-12-01', '10:30:00', 'Un recorrido por los lugares históricos de Madrid.', 4, 9),
('Concierto de Jazz', 12.00, '2023-12-05', '18:00:00', 'Una noche de jazz en el Mercado de San Miguel.', 1, 7),
('Ballet Clásico', 18.00, '2023-12-10', '19:30:00', 'Una presentación de ballet en el Teatro Real.', 3, 2),
('Exposición de Fotografía', 5.00, '2023-12-15', '12:00:00', 'Una muestra de fotografías artísticas en el Palacio Real.', 2, 6),
('Noche de Flamenco', 15.00, '2023-12-20', '21:00:00', 'Disfruta de un espectáculo de flamenco en la Glorieta de Cibeles.', 1, 8),
('Teatro Experimental', 10.00, '2023-12-25', '19:00:00', 'Una obra de teatro experimental en un lugar sorprendente.', 3, 5),
('Concierto de Piano', 20.00, '2024-01-01', '15:30:00', 'Un recital de piano en el Museo del Prado.', 1, 1),
('Proyección de Documentales', 5.00, '2024-01-05', '16:00:00', 'Documentales inspiradores en el Cine Capitol.', 3, 3),
('Charla sobre Historia', 0.00, '2024-01-10', '14:00:00', 'Una charla educativa sobre la historia de Madrid.', 4, 8),
('Noche de Comedia', 10.00, '2024-01-15', '20:30:00', 'Risas garantizadas en un club de comedia en la Plaza Mayor.', 3, 5),
('Festival de Danza', 15.00, '2024-01-20', '17:00:00', 'Bailes emocionantes en el Palacio Real.', 2, 6),
('Concierto de Folk', 12.00, '2024-01-25', '19:00:00', 'Música folk en el Mercado de San Miguel.', 1, 7),
('Exhibición de Esculturas', 0.00, '2024-02-01', '11:00:00', 'Esculturas artísticas en el Parque del Retiro.', 2, 4),
('Concierto de Blues', 18.00, '2024-02-05', '20:00:00', 'Una noche de blues en la Plaza Mayor.', 1, 5),
('Taller de Pintura', 10.00, '2024-02-10', '15:00:00', 'Aprende a pintar en un taller artístico.', 4, 7),
('Noche de Ópera', 22.00, '2024-02-15', '19:30:00', 'Una velada de ópera en el Teatro Real.', 3, 2),
('Exposición de Fotografía', 5.00, '2024-02-20', '12:00:00', 'Fotografías impresionantes en el Palacio Real.', 2, 6),
('Concierto de Jazz', 15.00, '2024-02-25', '18:30:00', 'Jazz en vivo en el Museo del Prado.', 1, 1),
('Charla de Ciencia', 0.00, '2024-03-01', '14:30:00', 'Una charla científica en la Glorieta de Cibeles.', 4, 8),
('Noche de Comedia', 12.00, '2024-03-05', '20:30:00', 'Risas aseguradas en un club de comedia en la Plaza Mayor.', 3, 5),
('Festival de Danza', 18.00, '2024-03-10', '18:00:00', 'Danzas emocionantes en el Palacio Real.', 2, 6),
('Concierto de Folk', 10.00, '2024-03-15', '19:00:00', 'Música folk en vivo en el Mercado de San Miguel.', 1, 7),
('Exhibición de Esculturas', 0.00, '2024-03-20', '11:00:00', 'Esculturas artísticas en el Parque del Retiro.', 2, 4),
('Concierto de Blues', 18.00, '2024-03-25', '20:00:00', 'Una noche de blues en la Plaza Mayor.', 1, 5),
('Taller de Pintura', 12.00, '2024-04-01', '15:00:00', 'Aprende a pintar en un taller artístico.', 4, 7),
('Noche de Ópera', 24.00, '2024-04-05', '19:30:00', 'Una velada de ópera en el Teatro Real.', 3, 2),
('Exposición de Fotografía', 5.00, '2024-04-10', '12:00:00', 'Fotografías impresionantes en el Palacio Real.', 2, 6),
('Concierto de Jazz', 15.00, '2024-04-15', '18:30:00', 'Jazz en vivo en el Museo del Prado.', 1, 1),
('Charla de Ciencia', 0.00, '2024-04-20', '14:30:00', 'Una charla científica en la Glorieta de Cibeles.', 4, 8),
('Noche de Comedia', 12.00, '2024-04-25', '20:30:00', 'Risas aseguradas en un club de comedia en la Plaza Mayor.', 3, 5),
('Festival de Danza', 18.00, '2024-05-01', '18:00:00', 'Danzas emocionantes en el Palacio Real.', 2, 6),
('Concierto de Folk', 10.00, '2024-05-05', '19:00:00', 'Música folk en vivo en el Mercado de San Miguel.', 1, 7),
('Exhibición de Esculturas', 0.00, '2024-05-10', '11:00:00', 'Esculturas artísticas en el Parque del Retiro.', 2, 4),
('Concierto de Blues', 18.00, '2024-05-15', '20:00:00', 'Una noche de blues en la Plaza Mayor.', 1, 5);

INSERT INTO PARTICIPACION (asistencia, evaluacion, rol, fk_persona_id, fk_evento_id) 
VALUES
(1, 4, NULL, 1, 1),
(1, 4, NULL, 2, 2),
(1, 3, NULL, 3, 3),
(1, 5, NULL, 4, 4),
(1, 4, NULL, 5, 5),
(1, 4, NULL, 6, 6),
(1, 3, NULL, 7, 7),
(1, 5, NULL, 8, 8),
(1, 4, NULL, 9, 9),
(1, 5, NULL, 10, 10),
(1, 4, NULL, 11, 11),
(0, NULL, NULL, 12, 12),
(1, 4, NULL, 13, 13),
(1, 4, NULL, 14, 14),
(1, 3, NULL, 15, 15),
(1, 5, NULL, 16, 16),
(0, NULL, NULL, 1, 17),
(1, 4, NULL, 2, 18),
(1, 3, NULL, 3, 19),
(1, 5, NULL, 4, 20),
(1, 4, NULL, 5, 21),
(1, 4, NULL, 6, 22),
(1, 3, NULL, 7, 23),
(1, 5, NULL, 8, 24),
(0, NULL, NULL, 9, 25),
(1, 5, NULL, 10, 26),
(1, 4, NULL, 11, 27),
(1, 3, NULL, 12, 28),
(1, 4, NULL, 13, 29),
(1, 4, NULL, 14, 30),
(1, 3, NULL, 15, 31),
(1, 5, NULL, 16, 32),
(1, 4, NULL, 1, 33),
(1, 4, NULL, 2, 34),
(1, 3, NULL, 3, 35),
(1, 5, NULL, 4, 36),
(1, 4, NULL, 5, 37),
(0, NULL, NULL, 6, 38),
(0, NULL, NULL, 7, 39),
(1, 5, NULL, 8, 40),
(1, 4, NULL, 9, 15),
(1, 5, NULL, 10, 25),
(1, 4, NULL, 11, 37),
(1, 3, NULL, 12, 11),
(1, 4, NULL, 13, 22),
(1, 4, NULL, 14, 28),
(1, 3, NULL, 15, 16),
(1, 5, NULL, 16, 27),
(1, 4, NULL, 1, 7),
(1, 4, NULL, 2, 36),
(NULL, NULL, 'Romeo', 1, 1),
(NULL, NULL, 'Julieta', 2, 2),
(NULL, NULL, 'Batman', 3, 3),
(NULL, NULL, 'Robin', 4, 4),
(NULL, NULL, 'Jason', 5, 5),
(NULL, NULL, 'Hercules', 6, 6),
(NULL, NULL, 'Helena', 7, 7),
(NULL, NULL, 'Paris', 8, 8),
(NULL, NULL, 'John', 9, 9),
(NULL, NULL, 'Ygrette', 10, 10),
(NULL, NULL, 'Jessy', 11, 11),
(NULL, NULL, 'Steve', 12, 12),
(NULL, NULL, 'Laura', 13, 13),
(NULL, NULL, 'Anabel', 14, 14),
(NULL, NULL, 'Alicia', 15, 15),
(NULL, NULL, 'Rick', 16, 16),
(NULL, NULL, 'Summer', 8, 9),
(NULL, NULL, 'Lisa', 2, 10),
(NULL, NULL, 'Marge', 3, 11),
(NULL, NULL, 'Bart', 4, 12),
(NULL, NULL, 'Maggie', 5, 13),
(NULL, NULL, 'Hommer', 6, 14),
(NULL, NULL, 'Bill', 7, 15),
(NULL, NULL, 'Led', 9, 16),
(NULL, NULL, 'Luis', 10, 16),
(NULL, NULL, 'Jose Rafael', 11, 17),
(NULL, NULL, 'Mario', 12, 18),
(NULL, NULL, 'Sebastian', 13, 19),
(NULL, NULL, 'Matias', 14, 20),
(NULL, NULL, 'Marta', 15, 21),
(NULL, NULL, 'Silvia', 16, 22),
(NULL, NULL, 'Morty', 1, 1),
(NULL, NULL, 'Alex', 2, 2),
(NULL, NULL, 'Richard', 3, 3),
(NULL, NULL, 'Sthef', 4, 4),
(NULL, NULL, 'Maria', 5, 5),
(NULL, NULL, 'Valeria', 6, 6),
(NULL, NULL, 'Valeria', 6, 6),
(NULL, NULL, NULL, 12, 12),
(NULL, NULL, NULL, 15, 15);

/*------------------------------------------------------------------------------------------------------
Consultas, modificaciones, borrados y vistas con enunciado 
-------------------------------------------------------------------------------------------------------*/

SELECT * FROM ERROR; -- probamos que el trigger funcione

SELECT -- eventos con su cantidad de asistentes e ingresos
  EVENTO.nombre,
  COUNT(PARTICIPACION.fk_persona_id) AS asistentes,
  SUM(EVENTO.precio_entrada) AS ingresos
FROM EVENTO
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
WHERE EVENTO.evento_id = PARTICIPACION.fk_evento_id
AND PARTICIPACION.rol IS NULL
GROUP BY EVENTO.nombre
ORDER BY asistentes DESC;

SELECT -- Veces que ha actuado una persona en diferentes eventos pero en una ubicacion
  UBICACION.nombre,
  PERSONA.nombre,
  COUNT(EVENTO.evento_id) AS eventos_participados
FROM EVENTO
JOIN UBICACION ON EVENTO.fk_ubicacion_id = UBICACION.ubicacion_id
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
WHERE PARTICIPACION.rol IS NOT NULL
GROUP BY UBICACION.nombre, PERSONA.nombre
ORDER BY eventos_participados DESC;

SELECT -- Veces que ha asistido una persona a diferentes eventos pero en una misma ubicacion
  UBICACION.nombre,
  PERSONA.nombre,
  COUNT(EVENTO.evento_id) AS eventos_participados
FROM EVENTO
JOIN UBICACION ON EVENTO.fk_ubicacion_id = UBICACION.ubicacion_id
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
WHERE PARTICIPACION.rol IS NULL
GROUP BY UBICACION.nombre, PERSONA.nombre
ORDER BY eventos_participados DESC;

SELECT -- Eventos con mas entradas vendidas por fecha
  EVENTO.fecha,
  EVENTO.nombre,
  COUNT(PARTICIPACION.participacion_id) AS entradas_vendidas
FROM EVENTO
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
GROUP BY EVENTO.fecha
ORDER BY entradas_vendidas DESC;

SELECT -- Entusiasmo por evento 
  EVENTO.nombre,
  COUNT(PARTICIPACION.participacion_id) AS participantes,
  AVG(PARTICIPACION.evaluacion) AS media_evaluaciones
FROM EVENTO
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
GROUP BY EVENTO.nombre
ORDER BY media_evaluaciones DESC;

SELECT -- ingresos, egresos y ganancias de cada evento, esto excluye a los eventos que no tienen actores, ya que el enunciado menciona que debe tener al menos uno, de igual forma se podria hacer a traves de LEFT JOINS, abajo dejo el cambio 
	TABLA.ubicacion,
    TABLA.evento,
	TABLA.egresos_actores + TABLA.egresos_alquiler AS egresos,
    TABLA.ingresos_entradas - TABLA.egresos_actores - TABLA.egresos_alquiler AS ganancias
FROM
(SELECT evento_id,
    SUM(EVENTO.precio_entrada) AS ingresos,
    SUM(UBICACION.precio_alquiler) AS egresos_alquiler,
    SUM(PERSONA.cache) AS egresos_actores,
    SUM(EVENTO.precio_entrada) AS ingresos_entradas,
    UBICACION.nombre AS ubicacion,
    EVENTO.nombre AS evento
FROM EVENTO
INNER JOIN UBICACION ON EVENTO.fk_ubicacion_id = UBICACION.ubicacion_id
LEFT JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
INNER JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
WHERE PARTICIPACION.rol IS NOT NULL
GROUP BY evento_id) AS tabla;

SELECT -- ingresos, egresos y ganancias de cada evento incluso si no tiene actores
  TABLA.ubicacion,
  TABLA.evento,
  TABLA.ingresos AS ingresos,
  TABLA.egresos_actores + TABLA.egresos_alquiler AS egresos,
  TABLA.ingresos_entradas - TABLA.egresos_actores - TABLA.egresos_alquiler AS ganancias
FROM
(
  SELECT
    evento_id,
    SUM(EVENTO.precio_entrada) AS ingresos,
    SUM(UBICACION.precio_alquiler) AS egresos_alquiler,
    SUM(PERSONA.cache) AS egresos_actores,
    SUM(EVENTO.precio_entrada) AS ingresos_entradas,
    UBICACION.nombre AS ubicacion,
    EVENTO.nombre AS evento
  FROM EVENTO
  LEFT JOIN UBICACION ON EVENTO.fk_ubicacion_id = UBICACION.ubicacion_id
  LEFT JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
LEFT JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
  GROUP BY evento_id
) AS TABLA;

SELECT -- Participacion de actores por tipo de actividad
  PERSONA.nombre,
  PERSONA.primer_apellido,
  PERSONA.segundo_apellido,
  ACTIVIDAD.tipo,
  COUNT(EVENTO.evento_id) AS eventos_participados
FROM
  evento
  JOIN ACTIVIDAD ON EVENTO.fk_actividad_id = ACTIVIDAD.actividad_id
  JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
  JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
GROUP BY
  ACTIVIDAD.tipo,
  PERSONA.persona_id
ORDER BY
  eventos_participados DESC;

SELECT -- Ubicacion con mas eventos
  UBICACION.nombre,
  COUNT(EVENTO.evento_id) AS eventos_totales
FROM
  EVENTO
  JOIN UBICACION ON EVENTO.fk_ubicacion_id = UBICACION.ubicacion_id
GROUP BY
  UBICACION.nombre
ORDER BY
  eventos_totales DESC;
  
SELECT -- Cantidad de eventos por actividad (tipo de evento)
  ACTIVIDAD.tipo,
  COUNT(EVENTO.evento_id) AS eventos_totales
FROM EVENTO
JOIN ACTIVIDAD ON EVENTO.fk_actividad_id = ACTIVIDAD.actividad_id
GROUP BY ACTIVIDAD.tipo
ORDER BY eventos_totales DESC;

SELECT -- Promedio de calificaciones por persona
  PERSONA.nombre,
  AVG(PARTICIPACION.evaluacion) AS avg_puntaje
FROM PARTICIPACION
JOIN PERSONA ON PARTICIPACION.fk_persona_id = PERSONA.persona_id
WHERE PARTICIPACION.rol IS NULL
GROUP BY PERSONA.nombre
ORDER BY avg_puntaje DESC;


CREATE VIEW AVG_EVENTO AS -- Vista con el promedio de evaluacion por evento
SELECT
  ACTIVIDAD.tipo AS tipo,
  EVENTO.nombre AS nombre,
  AVG(PARTICIPACION.evaluacion) AS avg_puntaje
FROM EVENTO
JOIN ACTIVIDAD ON EVENTO.fk_actividad_id = ACTIVIDAD.actividad_id
JOIN PARTICIPACION ON EVENTO.evento_id = PARTICIPACION.fk_evento_id
GROUP BY ACTIVIDAD.tipo, EVENTO.nombre
ORDER BY avg_puntaje DESC;

SELECT -- Evento con mejor puntaje 
  AVG_EVENTO.tipo,
  AVG_EVENTO.nombre,
  MAX(AVG_EVENTO.avg_puntaje)
FROM AVG_EVENTO
GROUP BY AVG_EVENTO.tipo
ORDER BY AVG_EVENTO.avg_puntaje;

-- Drop de una tabla que no afecta nada

DROP TABLE IF EXISTS ERROR;

-- hay que desactivar en el workbenach el safe update/delete, esto es en preferencias, sql editor, safe uodate

DELETE FROM TELEFONO WHERE TELEFONO.numero LIKE '666%';

DELETE FROM TELEFONO WHERE numero = '666 123 456';

-- ejecutamos antes del update para ver las participaciones que tenia y despue para ver que ya no estan
SELECT *
FROM PARTICIPACION
WHERE fk_persona_id IN (
    SELECT persona_id
    FROM PERSONA
    WHERE nombre LIKE 'María'
    AND primer_apellido LIKE "García"
)
AND rol IS NULL;

-- le pasamos las participaciones como publico de María a Isabel
UPDATE PARTICIPACION
SET fk_persona_id = (
    SELECT persona_id
    FROM PERSONA
    WHERE nombre LIKE 'Isabel'
    AND primer_apellido LIKE "Sánchez"
)
WHERE fk_persona_id IN (
    SELECT persona_id
    FROM PERSONA
    WHERE nombre LIKE 'María'
    AND primer_apellido LIKE "García"
)
AND rol IS NULL;
