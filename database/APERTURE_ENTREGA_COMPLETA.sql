CREATE DATABASE IF NOT EXISTS aperture_entrega CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aperture_entrega;

CREATE TABLE IF NOT EXISTS sucursales (
 id_sucursal INT AUTO_INCREMENT PRIMARY KEY,
 nombre_sucursal VARCHAR(100) NOT NULL,
 direccion VARCHAR(255) NOT NULL,
 telefono VARCHAR(25),
 fecha_apertura DATE,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS salas (
 id_sala INT AUTO_INCREMENT PRIMARY KEY,
 id_sucursal INT NOT NULL,
 nombre_sala VARCHAR(60) NOT NULL,
 capacidad INT NOT NULL,
 tipo_sala VARCHAR(40) DEFAULT 'ESTANDAR',
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(id_sucursal, nombre_sala), CHECK(capacidad > 0),
 FOREIGN KEY(id_sucursal) REFERENCES sucursales(id_sucursal)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS asientos (
 id_asiento INT AUTO_INCREMENT PRIMARY KEY,
 id_sala INT NOT NULL,
 fila VARCHAR(5) NOT NULL,
 numero_asiento SMALLINT NOT NULL,
 activo BOOLEAN DEFAULT TRUE,
 UNIQUE(id_sala, fila, numero_asiento),
 CHECK(numero_asiento > 0),
 FOREIGN KEY(id_sala) REFERENCES salas(id_sala)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS empleados (
 id_empleado INT AUTO_INCREMENT PRIMARY KEY,
 numero_empleado VARCHAR(20) NOT NULL UNIQUE,
 nombre_empleado VARCHAR(80) NOT NULL,
 apellido_paterno VARCHAR(100) NOT NULL,
 apellido_materno VARCHAR(100) NOT NULL,
 telefono VARCHAR(25),
 correo VARCHAR(120) UNIQUE,
 fecha_contrato DATE NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS usuarios (
 id_usuario INT AUTO_INCREMENT PRIMARY KEY,
 id_empleado INT NOT NULL UNIQUE,
 nombre_usuario VARCHAR(60) NOT NULL UNIQUE,
 hash_contrasena VARCHAR(255) NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 ultimo_acceso DATETIME,
 fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS roles (
 id_rol INT AUTO_INCREMENT PRIMARY KEY,
 nombre_rol VARCHAR(50) NOT NULL UNIQUE,
 descripcion VARCHAR(255),
 activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

INSERT INTO roles (nombre_rol, descripcion) VALUES
('DIRECTOR_OPERACIONES', 'Supervisa todas las sucursales'),
('GERENTE_SUCURSAL', 'Administra exclusivamente su sucursal asignada'),
('EMPLEADO_TAQUILLA', 'Realiza ventas de boletos'),
('EMPLEADO_DULCERIA', 'Realiza ventas de dulceria'),
('ENCARGADO_PROGRAMACION', 'Gestiona carteleras y funciones'),
('ENCARGADO_INVENTARIO', 'Controla existencias y movimientos')
ON DUPLICATE KEY UPDATE descripcion = descripcion;

CREATE TABLE IF NOT EXISTS rol_usuario (
 id_usuario INT NOT NULL, id_rol INT NOT NULL,
 PRIMARY KEY(id_usuario, id_rol),
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
 FOREIGN KEY(id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS empleado_sucursal (
 id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
 id_empleado INT NOT NULL,
 id_sucursal INT NOT NULL,
 fecha_inicio DATE NOT NULL,
 fecha_fin DATE,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 FOREIGN KEY(id_empleado) REFERENCES empleados(id_empleado),
 FOREIGN KEY(id_sucursal) REFERENCES sucursales(id_sucursal)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS permisos (
 id_permiso INT AUTO_INCREMENT PRIMARY KEY,
 nombre_permiso VARCHAR(80) NOT NULL UNIQUE,
 descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rol_permiso (
 id_rol INT NOT NULL,
 id_permiso INT NOT NULL,
 PRIMARY KEY(id_rol, id_permiso),
 FOREIGN KEY(id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE,
 FOREIGN KEY(id_permiso) REFERENCES permisos(id_permiso) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS peliculas (
 id_pelicula INT AUTO_INCREMENT PRIMARY KEY,
 titulo VARCHAR(180) NOT NULL, sinopsis TEXT,
 duracion_minutos SMALLINT NOT NULL,
 clasificacion VARCHAR(10) NOT NULL,
 genero VARCHAR(80),
 idioma_original VARCHAR(50),
 fecha_estreno DATE, activo BOOLEAN NOT NULL DEFAULT TRUE,
 CHECK(duracion_minutos > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS carteleras (
 id_cartelera INT AUTO_INCREMENT PRIMARY KEY,
 id_sucursal INT NOT NULL,
 fecha_inicio DATE NOT NULL,
 fecha_fin DATE NOT NULL,
 estado ENUM('BORRADOR','PUBLICADA','FINALIZADA') DEFAULT 'BORRADOR',
 CHECK (fecha_fin >= fecha_inicio),
 FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cartelera_pelicula (
 id_cartelera INT NOT NULL,
 id_pelicula INT NOT NULL,
 PRIMARY KEY (id_cartelera, id_pelicula),
 FOREIGN KEY (id_cartelera) REFERENCES carteleras(id_cartelera),
 FOREIGN KEY (id_pelicula) REFERENCES peliculas(id_pelicula)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS funciones_cine (
 id_funcion INT AUTO_INCREMENT PRIMARY KEY,
 id_cartelera INT NOT NULL,
 id_pelicula INT NOT NULL,
 id_sala INT NOT NULL,
 fecha_inicio DATETIME NOT NULL,
 fecha_fin DATETIME NOT NULL,
 estado ENUM('PROGRAMADA','EN_CURSO','FINALIZADA','CANCELADA') DEFAULT 'PROGRAMADA',
 creada_por INT, fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK(fecha_fin > fecha_inicio),
 FOREIGN KEY(id_cartelera, id_pelicula) REFERENCES cartelera_pelicula(id_cartelera, id_pelicula),
 FOREIGN KEY(id_sala) REFERENCES salas(id_sala),
 FOREIGN KEY(creada_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 INDEX id_funcion_horario(id_sala, fecha_inicio, fecha_fin)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS precios_boletos (
 id_precio_boleto INT AUTO_INCREMENT PRIMARY KEY,
 id_sucursal INT NOT NULL,
 nombre_precio VARCHAR(60) NOT NULL,
 cantidad DECIMAL(10,2) NOT NULL,
 fecha_inicio DATE NOT NULL,
 fecha_fin DATE,
 activo BOOLEAN NOT NULL DEFAULT TRUE,
 CHECK(cantidad >= 0),
 CHECK(fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS promociones (
 id_promocion INT AUTO_INCREMENT PRIMARY KEY,
 nombre_promocion VARCHAR(120) NOT NULL, descripcion TEXT,
 tipo_descuento ENUM('PORCENTAJE','CANTIDAD_FIJA'),
 valor_descuento DECIMAL(10,2) NOT NULL,
 fecha_inicio DATETIME NOT NULL, fecha_fin DATETIME NOT NULL,
 texto_condiciones TEXT, activo BOOLEAN DEFAULT TRUE, creada_por INT,
 CHECK(valor_descuento >= 0),
 CHECK(tipo_descuento <> 'PORCENTAJE' OR valor_descuento <= 100),
 CHECK(fecha_fin >= fecha_inicio),
 FOREIGN KEY(creada_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS promocion_sucursal (
 id_promocion INT NOT NULL,
 id_sucursal INT NOT NULL,
 PRIMARY KEY(id_promocion, id_sucursal),
 FOREIGN KEY(id_promocion) REFERENCES promociones(id_promocion) ON DELETE CASCADE,
 FOREIGN KEY(id_sucursal) REFERENCES sucursales(id_sucursal) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ventas (
 id_venta BIGINT AUTO_INCREMENT PRIMARY KEY,
 id_sucursal INT NOT NULL, id_usuario INT,
 tipo_venta ENUM('TAQUILLA','DULCERIA') NOT NULL,
 fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
 descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
 total DECIMAL(10,2) NOT NULL DEFAULT 0,
 metodo_pago ENUM('EFECTIVO','TARJETA','TRANSFERENCIA','OTRO') DEFAULT 'EFECTIVO',
 estado ENUM('COMPLETADA','CANCELADA') DEFAULT 'COMPLETADA',
 CHECK(subtotal >= 0),
 CHECK(descuento >= 0),
 CHECK(total >= 0),
 CHECK(descuento <= subtotal),
 CHECK(total = subtotal - descuento),
 FOREIGN KEY(id_sucursal) REFERENCES sucursales(id_sucursal),
 FOREIGN KEY(id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 INDEX id_ventas_fecha(fecha_venta)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS boletos (
 id_boleto BIGINT AUTO_INCREMENT PRIMARY KEY,
 id_funcion INT NOT NULL,
 id_asiento INT NOT NULL,
 id_precio_boleto INT NOT NULL,
 id_promocion INT,
 id_venta BIGINT NOT NULL,
 precio_pagado DECIMAL(10,2) NOT NULL,
 estado ENUM('VENDIDO','CANCELADO','USADO') DEFAULT 'VENDIDO',
 fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK(precio_pagado >= 0),
 -- NULL permite conservar historico de boletos cancelados sin bloquear el asiento.
 asiento_vigente INT GENERATED ALWAYS AS
   (CASE WHEN estado IN ('VENDIDO','USADO') THEN id_asiento ELSE NULL END) STORED,
 UNIQUE KEY uq_boleto_asiento_vigente (id_funcion, asiento_vigente),
 FOREIGN KEY(id_funcion) REFERENCES funciones_cine(id_funcion),
 FOREIGN KEY(id_asiento) REFERENCES asientos(id_asiento),
 FOREIGN KEY(id_precio_boleto) REFERENCES precios_boletos(id_precio_boleto),
 FOREIGN KEY(id_promocion) REFERENCES promociones(id_promocion) ON DELETE SET NULL,
 FOREIGN KEY(id_venta) REFERENCES ventas(id_venta) 
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS productos (
 id_producto INT AUTO_INCREMENT PRIMARY KEY,
 nombre_producto VARCHAR(120) NOT NULL UNIQUE,
 descripcion VARCHAR(255),
 categoria VARCHAR(60),
 unidad_medida VARCHAR(20) DEFAULT 'PIEZA',
 activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS combos (
 id_combo INT AUTO_INCREMENT PRIMARY KEY,
 nombre_combo VARCHAR(120) NOT NULL UNIQUE,
 descripcion VARCHAR(255),
 activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS combo_productos (
 id_combo INT NOT NULL,
 id_producto INT NOT NULL,
 cantidad DECIMAL(10,2) NOT NULL,
 PRIMARY KEY(id_combo, id_producto),
 CHECK(cantidad > 0),
 FOREIGN KEY(id_combo) REFERENCES combos(id_combo) ON DELETE CASCADE,
 FOREIGN KEY(id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS precios_dulceria (
 id_precio INT AUTO_INCREMENT PRIMARY KEY,
 id_sucursal INT NOT NULL,
 id_producto INT,
 id_combo INT,
 precio DECIMAL(10,2) NOT NULL,
 fecha_inicio DATE NOT NULL,
 fecha_fin DATE,
 CHECK (precio >= 0),
 CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
 CHECK ((id_producto IS NOT NULL AND id_combo IS NULL) OR (id_producto IS NULL AND id_combo IS NOT NULL)),
 FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
 FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
 FOREIGN KEY (id_combo) REFERENCES combos(id_combo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS promocion_producto (
 id_promocion_producto INT AUTO_INCREMENT PRIMARY KEY,
 id_promocion INT NOT NULL,
 id_producto INT NULL,
 id_combo INT NULL,
 CHECK((id_producto IS NOT NULL AND id_combo IS NULL) OR (id_producto IS NULL AND id_combo IS NOT NULL)),
 FOREIGN KEY(id_promocion) REFERENCES promociones(id_promocion) ON DELETE CASCADE,
 FOREIGN KEY(id_producto) REFERENCES productos(id_producto),
 FOREIGN KEY(id_combo) REFERENCES combos(id_combo)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS detalles_venta (
    id_detalle BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_venta BIGINT NOT NULL,
    id_producto INT,
    id_combo INT,
    id_boleto BIGINT,
    descripcion VARCHAR(180) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_linea DECIMAL(10,2) NOT NULL,
    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0),
    CHECK (descuento >= 0),
    CHECK (total_linea >= 0),
    CHECK (descuento <= cantidad * precio_unitario),
    CHECK (total_linea = cantidad * precio_unitario - descuento),
    CHECK ((id_producto IS NOT NULL AND id_combo IS NULL AND id_boleto IS NULL) 
    OR (id_producto IS NULL AND id_combo IS NOT NULL AND id_boleto IS NULL)
    OR (id_producto IS NULL AND id_combo IS NULL AND id_boleto IS NOT NULL)),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
	FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
	FOREIGN KEY (id_combo) REFERENCES combos(id_combo),
    FOREIGN KEY (id_boleto) REFERENCES boletos(id_boleto)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS existencias (
    id_existencia INT AUTO_INCREMENT PRIMARY KEY,
    id_sucursal INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_actual DECIMAL(10,2) NOT NULL DEFAULT 0,
    cantidad_minima DECIMAL(10,2) NOT NULL DEFAULT 5,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (id_sucursal, id_producto),
    CHECK (cantidad_actual >= 0),
    CHECK (cantidad_minima >= 0),
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
	FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_existencia INT NOT NULL,
    id_usuario INT,
    tipo_movimiento ENUM('ENTRADA','SALIDA','AJUSTE') NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    motivo VARCHAR(255),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (cantidad > 0),
    FOREIGN KEY (id_existencia) REFERENCES existencias(id_existencia),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
	INDEX idx_movimientos_fecha(id_existencia, fecha_movimiento)
) ENGINE=InnoDB;

CREATE OR REPLACE VIEW vista_programacion AS
SELECT f.id_funcion, p.titulo AS pelicula, s.nombre_sucursal AS sucursal, sa.nombre_sala AS sala,
    f.fecha_inicio, f.fecha_fin, f.estado
FROM funciones_cine f
JOIN peliculas p ON p.id_pelicula = f.id_pelicula
JOIN salas sa ON sa.id_sala = f.id_sala
JOIN sucursales s ON s.id_sucursal = sa.id_sucursal;

CREATE OR REPLACE VIEW vista_ventas_diarias AS
SELECT DATE(v.fecha_venta) AS fecha, s.id_sucursal, s.nombre_sucursal, v.tipo_venta,
    COUNT(*) AS numero_ventas,
    SUM(v.subtotal) AS subtotal,
    SUM(v.descuento) AS descuentos,
    SUM(v.total) AS total
FROM ventas v
JOIN sucursales s ON s.id_sucursal = v.id_sucursal
WHERE v.estado = 'COMPLETADA'
GROUP BY DATE(v.fecha_venta), s.id_sucursal, s.nombre_sucursal, v.tipo_venta;



CREATE OR REPLACE VIEW vista_productos_baja_existencia AS
SELECT s.id_sucursal, s.nombre_sucursal, p.id_producto, p.nombre_producto, e.cantidad_actual, e.cantidad_minima
FROM existencias e
JOIN productos p ON p.id_producto = e.id_producto
JOIN sucursales s ON s.id_sucursal = e.id_sucursal
WHERE p.activo = TRUE AND e.cantidad_actual <= e.cantidad_minima;

-- ================================================================
-- REGLAS DE INTEGRIDAD (MySQL 8.0.16+)
-- ================================================================
-- NOTA: Este archivo crea la estructura, no inserta datos de negocio.
-- Los triggers se eliminan y recrean para facilitar su actualización.
-- Las operaciones de venta deben ejecutarse en transacciones desde
-- Spring Boot (START TRANSACTION / COMMIT / ROLLBACK).

DROP TRIGGER IF EXISTS trg_funcion_bi;
DROP TRIGGER IF EXISTS trg_funcion_bu;
DROP TRIGGER IF EXISTS trg_boleto_bi;
DROP TRIGGER IF EXISTS trg_boleto_bu;
DROP TRIGGER IF EXISTS trg_movimiento_bi;
DROP TRIGGER IF EXISTS trg_movimiento_ai;
DROP TRIGGER IF EXISTS trg_movimiento_bu;
DROP TRIGGER IF EXISTS trg_movimiento_bd;
DROP TRIGGER IF EXISTS trg_detalle_bi;
DROP TRIGGER IF EXISTS trg_detalle_bu;

DELIMITER $$

CREATE TRIGGER trg_funcion_bi BEFORE INSERT ON funciones_cine
FOR EACH ROW
BEGIN
  DECLARE v_sucursal_sala INT DEFAULT NULL;
  DECLARE v_sucursal_cartelera INT DEFAULT NULL;
  DECLARE v_inicio DATE DEFAULT NULL;
  DECLARE v_fin DATE DEFAULT NULL;
  SELECT id_sucursal INTO v_sucursal_sala FROM salas WHERE id_sala = NEW.id_sala;
  SELECT id_sucursal, fecha_inicio, fecha_fin INTO v_sucursal_cartelera, v_inicio, v_fin
    FROM carteleras WHERE id_cartelera = NEW.id_cartelera;
  IF v_sucursal_sala IS NULL OR v_sucursal_cartelera IS NULL OR v_sucursal_sala <> v_sucursal_cartelera THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala y la cartelera deben pertenecer a la misma sucursal';
  END IF;
  IF DATE(NEW.fecha_inicio) < v_inicio OR DATE(NEW.fecha_inicio) > v_fin THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La funcion debe iniciar dentro del periodo de cartelera';
  END IF;
  IF NEW.estado <> 'CANCELADA' AND EXISTS (
    SELECT 1 FROM funciones_cine f WHERE f.id_sala = NEW.id_sala
      AND f.estado <> 'CANCELADA'
      AND NEW.fecha_inicio < f.fecha_fin AND NEW.fecha_fin > f.fecha_inicio
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existe otra funcion en el mismo horario y sala';
  END IF;
END$$

CREATE TRIGGER trg_funcion_bu BEFORE UPDATE ON funciones_cine
FOR EACH ROW
BEGIN
  DECLARE v_sucursal_sala INT DEFAULT NULL;
  DECLARE v_sucursal_cartelera INT DEFAULT NULL;
  DECLARE v_inicio DATE DEFAULT NULL;
  DECLARE v_fin DATE DEFAULT NULL;
  SELECT id_sucursal INTO v_sucursal_sala FROM salas WHERE id_sala = NEW.id_sala;
  SELECT id_sucursal, fecha_inicio, fecha_fin INTO v_sucursal_cartelera, v_inicio, v_fin
    FROM carteleras WHERE id_cartelera = NEW.id_cartelera;
  IF v_sucursal_sala IS NULL OR v_sucursal_cartelera IS NULL OR v_sucursal_sala <> v_sucursal_cartelera THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sala y la cartelera deben pertenecer a la misma sucursal';
  END IF;
  IF DATE(NEW.fecha_inicio) < v_inicio OR DATE(NEW.fecha_inicio) > v_fin THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La funcion debe iniciar dentro del periodo de cartelera';
  END IF;
  IF NEW.estado <> 'CANCELADA' AND EXISTS (
    SELECT 1 FROM funciones_cine f WHERE f.id_sala = NEW.id_sala
      AND f.id_funcion <> OLD.id_funcion AND f.estado <> 'CANCELADA'
      AND NEW.fecha_inicio < f.fecha_fin AND NEW.fecha_fin > f.fecha_inicio
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existe otra funcion en el mismo horario y sala';
  END IF;
  IF EXISTS (SELECT 1 FROM boletos b WHERE b.id_funcion = OLD.id_funcion AND b.estado <> 'CANCELADO')
     AND (NEW.id_sala <> OLD.id_sala OR NEW.id_pelicula <> OLD.id_pelicula OR NEW.fecha_inicio <> OLD.fecha_inicio) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede reprogramar una funcion con boletos vigentes';
  END IF;
END$$

CREATE TRIGGER trg_boleto_bi BEFORE INSERT ON boletos
FOR EACH ROW
BEGIN
  DECLARE v_sala_funcion INT;
  DECLARE v_sucursal_funcion INT;
  DECLARE v_sala_asiento INT;
  DECLARE v_sucursal_precio INT;
  DECLARE v_sucursal_venta INT;
  DECLARE v_tipo_venta VARCHAR(20);
  DECLARE v_estado_funcion VARCHAR(20);
  SELECT f.id_sala, s.id_sucursal, f.estado
    INTO v_sala_funcion, v_sucursal_funcion, v_estado_funcion
    FROM funciones_cine f JOIN salas s ON s.id_sala = f.id_sala WHERE f.id_funcion = NEW.id_funcion;
  SELECT id_sala INTO v_sala_asiento FROM asientos WHERE id_asiento = NEW.id_asiento;
  SELECT id_sucursal INTO v_sucursal_precio FROM precios_boletos WHERE id_precio_boleto = NEW.id_precio_boleto;
  SELECT id_sucursal, tipo_venta INTO v_sucursal_venta, v_tipo_venta FROM ventas WHERE id_venta = NEW.id_venta;
  IF v_sala_funcion IS NULL OR v_sala_asiento <> v_sala_funcion THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El asiento no pertenece a la sala de la funcion';
  END IF;
  IF v_sucursal_funcion <> v_sucursal_precio OR v_sucursal_funcion <> v_sucursal_venta OR v_tipo_venta <> 'TAQUILLA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta o precio de boleto incompatible con la sucursal';
  END IF;
  IF v_estado_funcion = 'CANCELADA' AND NEW.estado <> 'CANCELADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se venden boletos de funciones canceladas';
  END IF;
END$$

CREATE TRIGGER trg_boleto_bu BEFORE UPDATE ON boletos
FOR EACH ROW
BEGIN
  IF NEW.id_funcion <> OLD.id_funcion OR NEW.id_asiento <> OLD.id_asiento
     OR NEW.id_venta <> OLD.id_venta OR NEW.id_precio_boleto <> OLD.id_precio_boleto THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No reasignar boletos; cancelar y emitir otro';
  END IF;
  IF OLD.estado = 'USADO' AND NEW.estado <> 'USADO' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un boleto usado no puede volver a estar disponible';
  END IF;
END$$

CREATE TRIGGER trg_movimiento_bi BEFORE INSERT ON movimientos_inventario
FOR EACH ROW
BEGIN
  DECLARE v_actual DECIMAL(10,2);
  -- Bloqueo exclusivo hasta COMMIT/ROLLBACK: serializa salidas concurrentes.
  SELECT cantidad_actual INTO v_actual
  FROM existencias WHERE id_existencia = NEW.id_existencia FOR UPDATE;
  IF NEW.tipo_movimiento = 'SALIDA' AND v_actual < NEW.cantidad THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Existencia insuficiente';
  END IF;
  -- AJUSTE representa incremento; para reducir stock usar SALIDA.
  -- Ante deadlocks, la aplicacion debe reintentar la transaccion completa.
END$$

CREATE TRIGGER trg_movimiento_ai AFTER INSERT ON movimientos_inventario
FOR EACH ROW
BEGIN
  UPDATE existencias
  SET cantidad_actual = cantidad_actual + CASE WHEN NEW.tipo_movimiento = 'SALIDA' THEN -NEW.cantidad ELSE NEW.cantidad END
  WHERE id_existencia = NEW.id_existencia;
END$$

CREATE TRIGGER trg_movimiento_bu BEFORE UPDATE ON movimientos_inventario
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los movimientos son inmutables; registrar un movimiento compensatorio';
END$$

CREATE TRIGGER trg_movimiento_bd BEFORE DELETE ON movimientos_inventario
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No eliminar movimientos de inventario';
END$$

CREATE TRIGGER trg_detalle_bi BEFORE INSERT ON detalles_venta
FOR EACH ROW
BEGIN
  DECLARE v_tipo VARCHAR(20);
  DECLARE v_venta_boleto BIGINT;
  SELECT tipo_venta INTO v_tipo FROM ventas WHERE id_venta = NEW.id_venta;
  IF (NEW.id_boleto IS NOT NULL AND v_tipo <> 'TAQUILLA')
    OR (NEW.id_boleto IS NULL AND v_tipo <> 'DULCERIA') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de detalle incompatible con la venta';
  END IF;
  IF NEW.id_boleto IS NOT NULL THEN
    SELECT id_venta INTO v_venta_boleto FROM boletos WHERE id_boleto = NEW.id_boleto;
    IF v_venta_boleto <> NEW.id_venta THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El boleto corresponde a otra venta';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_detalle_bu BEFORE UPDATE ON detalles_venta
FOR EACH ROW
BEGIN
  IF NEW.id_venta <> OLD.id_venta THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No trasladar detalles entre ventas';
  END IF;
END$$

DELIMITER ;

-- Índices auxiliares para consultas habituales
CREATE INDEX idx_funciones_fecha ON funciones_cine (fecha_inicio, estado);
CREATE INDEX idx_boletos_venta ON boletos (id_venta);
CREATE INDEX idx_detalles_venta ON detalles_venta (id_venta);
CREATE INDEX idx_asignacion_empleado ON empleado_sucursal (id_empleado, activo);

-- ================================================================
-- COMPROBACION DE ESTRUCTURA: resultado esperado 27 / 3 / 10
-- ================================================================
SELECT
  (SELECT COUNT(*) FROM information_schema.tables
   WHERE table_schema = 'aperture_entrega' AND table_type = 'BASE TABLE') AS tablas,
  (SELECT COUNT(*) FROM information_schema.views
   WHERE table_schema = 'aperture_entrega') AS vistas,
  (SELECT COUNT(*) FROM information_schema.triggers
   WHERE trigger_schema = 'aperture_entrega') AS triggers;

-- Verifica especificamente que exista el trigger de bloqueo de inventario:
SELECT TRIGGER_NAME, EVENT_MANIPULATION, ACTION_TIMING
FROM information_schema.triggers
WHERE TRIGGER_SCHEMA = 'aperture_entrega'
  AND TRIGGER_NAME IN ('trg_movimiento_bi', 'trg_movimiento_ai')
ORDER BY TRIGGER_NAME;

-- IMPORTANTE: la prueba de concurrencia REAL requiere dos sesiones SQL
-- simultaneas, con transacciones separadas. Este SELECT solo comprueba
-- la instalacion del trigger, no prueba carreras concurrentes.


-- ========== DATOS DE DEMOSTRACION ==========
-- APERTURE: DATOS DEMOSTRATIVOS PARA aperture_entrega

-- Referencia real: Cine Tonalá, Tonalá 261, Roma Sur, CDMX (Secretaría de Cultura).

-- Salas, asientos, horarios, personal, precios, ventas e inventario: SIMULADOS; NO datos de Cine Tonalá.

-- Películas: obras reales; duraciones de referencia, pueden variar según edición.

-- Clasificación SC = sin clasificación mexicana verificada; fecha_estreno NULL evita fechas ficticias.

-- EJECUTAR UNA SOLA VEZ sobre aperture_entrega recién creada. NO ejecutar sobre aperture.
-- Usuarios activos: nombre_usuario = clave de personal APT-001 ... APT-016; clave de prueba ApertureDemo2026!
-- hash_contrasena: PBKDF2-SHA256; el Servlet debe verificar el hash, NO comparar texto plano.
-- No usar credenciales demo en produccion. No conectar Android directamente a MySQL.

USE aperture_entrega;
START TRANSACTION;

INSERT INTO sucursales (id_sucursal,nombre_sucursal,direccion,telefono,fecha_apertura) VALUES (1,'Aperture - sede piloto (referencia: Cine Tonalá)','Tonalá 261, Col. Roma Sur, Cuauhtémoc, Ciudad de México',NULL,NULL);

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (1,1,'Sala 1',24,'ESTANDAR');

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (2,1,'Sala 2',28,'ESTANDAR');

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (3,1,'Sala 3',32,'ESTANDAR');

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (4,1,'Sala 4',24,'ESTANDAR');

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (5,1,'Sala 5',36,'ESTANDAR');

INSERT INTO salas (id_sala,id_sucursal,nombre_sala,capacidad,tipo_sala) VALUES (6,1,'Sala 6',28,'ESTANDAR');

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (1,1,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (2,1,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (3,1,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (4,1,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (5,1,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (6,1,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (7,1,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (8,1,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (9,1,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (10,1,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (11,1,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (12,1,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (13,1,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (14,1,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (15,1,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (16,1,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (17,1,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (18,1,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (19,1,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (20,1,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (21,1,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (22,1,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (23,1,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (24,1,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (25,2,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (26,2,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (27,2,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (28,2,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (29,2,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (30,2,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (31,2,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (32,2,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (33,2,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (34,2,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (35,2,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (36,2,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (37,2,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (38,2,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (39,2,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (40,2,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (41,2,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (42,2,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (43,2,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (44,2,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (45,2,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (46,2,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (47,2,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (48,2,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (49,2,'G',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (50,2,'G',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (51,2,'G',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (52,2,'G',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (53,3,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (54,3,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (55,3,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (56,3,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (57,3,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (58,3,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (59,3,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (60,3,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (61,3,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (62,3,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (63,3,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (64,3,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (65,3,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (66,3,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (67,3,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (68,3,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (69,3,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (70,3,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (71,3,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (72,3,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (73,3,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (74,3,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (75,3,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (76,3,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (77,3,'G',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (78,3,'G',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (79,3,'G',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (80,3,'G',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (81,3,'H',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (82,3,'H',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (83,3,'H',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (84,3,'H',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (85,4,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (86,4,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (87,4,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (88,4,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (89,4,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (90,4,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (91,4,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (92,4,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (93,4,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (94,4,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (95,4,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (96,4,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (97,4,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (98,4,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (99,4,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (100,4,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (101,4,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (102,4,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (103,4,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (104,4,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (105,4,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (106,4,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (107,4,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (108,4,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (109,5,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (110,5,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (111,5,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (112,5,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (113,5,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (114,5,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (115,5,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (116,5,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (117,5,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (118,5,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (119,5,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (120,5,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (121,5,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (122,5,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (123,5,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (124,5,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (125,5,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (126,5,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (127,5,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (128,5,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (129,5,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (130,5,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (131,5,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (132,5,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (133,5,'G',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (134,5,'G',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (135,5,'G',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (136,5,'G',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (137,5,'H',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (138,5,'H',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (139,5,'H',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (140,5,'H',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (141,5,'I',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (142,5,'I',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (143,5,'I',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (144,5,'I',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (145,6,'A',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (146,6,'A',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (147,6,'A',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (148,6,'A',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (149,6,'B',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (150,6,'B',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (151,6,'B',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (152,6,'B',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (153,6,'C',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (154,6,'C',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (155,6,'C',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (156,6,'C',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (157,6,'D',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (158,6,'D',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (159,6,'D',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (160,6,'D',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (161,6,'E',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (162,6,'E',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (163,6,'E',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (164,6,'E',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (165,6,'F',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (166,6,'F',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (167,6,'F',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (168,6,'F',4);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (169,6,'G',1);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (170,6,'G',2);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (171,6,'G',3);

INSERT INTO asientos (id_asiento,id_sala,fila,numero_asiento) VALUES (172,6,'G',4);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (1,'The Shawshank Redemption',NULL,142,'SC','Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (2,'The Godfather',NULL,175,'SC','Crimen / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (3,'The Dark Knight',NULL,152,'SC','Acción / Crimen','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (4,'The Godfather Part II',NULL,202,'SC','Crimen / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (5,'12 Angry Men',NULL,96,'SC','Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (6,'Schindler’s List',NULL,195,'SC','Drama / Historia','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (7,'The Lord of the Rings: The Fellowship of the Ring',NULL,178,'SC','Fantasía / Aventura','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (8,'Pulp Fiction',NULL,154,'SC','Crimen / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (9,'The Good, the Bad and the Ugly',NULL,178,'SC','Wéstern','Italiano',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (10,'Fight Club',NULL,139,'SC','Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (11,'Forrest Gump',NULL,142,'SC','Drama / Romance','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (12,'Inception',NULL,148,'SC','Ciencia ficción / Acción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (13,'The Lord of the Rings: The Two Towers',NULL,179,'SC','Fantasía / Aventura','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (14,'The Lord of the Rings: The Return of the King',NULL,201,'SC','Fantasía / Aventura','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (15,'Star Wars: Episode V - The Empire Strikes Back',NULL,124,'SC','Ciencia ficción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (16,'The Matrix',NULL,136,'SC','Ciencia ficción / Acción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (17,'Goodfellas',NULL,145,'SC','Crimen / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (18,'One Flew Over the Cuckoo’s Nest',NULL,133,'SC','Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (19,'Se7en',NULL,127,'SC','Suspenso / Crimen','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (20,'The Silence of the Lambs',NULL,118,'SC','Suspenso','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (21,'Saving Private Ryan',NULL,169,'SC','Bélico / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (22,'Interstellar',NULL,169,'SC','Ciencia ficción / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (23,'The Green Mile',NULL,189,'SC','Drama / Fantasía','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (24,'Spirited Away',NULL,125,'SC','Animación / Fantasía','Japonés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (25,'Parasite',NULL,132,'SC','Suspenso / Drama','Coreano',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (26,'Whiplash',NULL,106,'SC','Drama / Música','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (27,'The Prestige',NULL,130,'SC','Drama / Misterio','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (28,'The Departed',NULL,151,'SC','Crimen / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (29,'Gladiator',NULL,155,'SC','Acción / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (30,'The Lion King',NULL,88,'SC','Animación / Aventura','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (31,'Back to the Future',NULL,116,'SC','Ciencia ficción / Comedia','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (32,'Alien',NULL,117,'SC','Terror / Ciencia ficción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (33,'Apocalypse Now',NULL,147,'SC','Bélico / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (34,'Memento',NULL,113,'SC','Misterio / Suspenso','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (35,'WALL·E',NULL,98,'SC','Animación / Ciencia ficción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (36,'Coco',NULL,105,'SC','Animación / Familiar','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (37,'Ratatouille',NULL,111,'SC','Animación / Comedia','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (38,'Up',NULL,96,'SC','Animación / Aventura','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (39,'Toy Story',NULL,81,'SC','Animación / Familiar','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (40,'Inside Out',NULL,95,'SC','Animación / Familiar','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (41,'The Truman Show',NULL,103,'SC','Drama / Ciencia ficción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (42,'Eternal Sunshine of the Spotless Mind',NULL,108,'SC','Romance / Ciencia ficción','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (43,'Amélie',NULL,122,'SC','Comedia / Romance','Francés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (44,'Cinema Paradiso',NULL,155,'SC','Drama','Italiano',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (45,'Pan’s Labyrinth',NULL,118,'SC','Fantasía / Drama','Español',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (46,'Roma',NULL,135,'SC','Drama','Español',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (47,'Y tu mamá también',NULL,106,'SC','Drama','Español',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (48,'Amores perros',NULL,154,'SC','Drama','Español',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (49,'The Grand Budapest Hotel',NULL,99,'SC','Comedia / Drama','Inglés',NULL);

INSERT INTO peliculas (id_pelicula,titulo,sinopsis,duracion_minutos,clasificacion,genero,idioma_original,fecha_estreno) VALUES (50,'La La Land',NULL,128,'SC','Musical / Romance','Inglés',NULL);

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (1,'APT-001','Renata','Villaseñor','Alcocer','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (2,'APT-002','Sebastián','Arriaga','Valdés','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (3,'APT-003','Miranda','Elizondo','Castañeda','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (4,'APT-004','Nicolás','Santillán','Robles','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (5,'APT-005','Emilia','Ledesma','Figueroa','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (6,'APT-006','Leonardo','Iturbide','Salcedo','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (7,'APT-007','Julieta','Zúñiga','Montiel','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (8,'APT-008','Emiliano','Echeverría','Solís','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (9,'APT-009','Isabela','Treviño','Aranda','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (10,'APT-010','Santiago','Urrutia','Beltrán','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (11,'APT-011','Natalia','Escalante','Mijares','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (12,'APT-012','Matías','Valcárcel','Orozco','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (13,'APT-013','Regina','Altamirano','Vélez','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (14,'APT-014','Adrián','Balmaceda','Ríos','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (15,'APT-015','Luciana','Cárdenas','Olmedo','2026-01-15');

INSERT INTO empleados (id_empleado,numero_empleado,nombre_empleado,apellido_paterno,apellido_materno,fecha_contrato) VALUES (16,'APT-016','Gael','Mondragón','Ibarra','2026-01-15');

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (1,1,'APT-001','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (2,2,'APT-002','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (3,3,'APT-003','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (4,4,'APT-004','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (5,5,'APT-005','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (6,6,'APT-006','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (7,7,'APT-007','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (8,8,'APT-008','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (9,9,'APT-009','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (10,10,'APT-010','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (11,11,'APT-011','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (12,12,'APT-012','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (13,13,'APT-013','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (14,14,'APT-014','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (15,15,'APT-015','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO usuarios (id_usuario,id_empleado,nombre_usuario,hash_contrasena,activo) VALUES (16,16,'APT-016','pbkdf2_sha256$120000$YXBlcnR1cmUtZGVtby0yMDI2LXYx$emmUJ+IouAFyAoSrjFb8UQcHgycWvDI5RSNXyVNYYAM=',TRUE);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (1,1);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (2,2);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (3,3);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (4,3);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (5,3);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (6,4);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (7,4);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (8,4);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (9,5);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (10,6);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (11,3);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (12,4);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (13,6);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (14,5);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (15,3);

INSERT INTO rol_usuario (id_usuario,id_rol) VALUES (16,4);

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (2,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (3,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (4,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (5,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (6,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (7,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (8,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (9,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (10,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (11,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (12,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (13,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (14,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (15,1,'2026-01-15');

INSERT INTO empleado_sucursal (id_empleado,id_sucursal,fecha_inicio) VALUES (16,1,'2026-01-15');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (1,'CONSULTAR_SUCURSALES','Consultar sucursales');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (2,'GESTIONAR_SUCURSALES','Administrar sucursales');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (3,'GESTIONAR_SALAS','Administrar salas');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (4,'GESTIONAR_PELICULAS','Administrar catálogo de películas');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (5,'GESTIONAR_CARTELERAS','Programar carteleras');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (6,'GESTIONAR_FUNCIONES','Programar funciones');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (7,'VENDER_BOLETOS','Vender boletos');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (8,'VENDER_DULCERIA','Vender dulcería');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (9,'GESTIONAR_INVENTARIO','Registrar movimientos de inventario');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (10,'GESTIONAR_EMPLEADOS','Administrar empleados');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (11,'CONSULTAR_REPORTES','Consultar reportes');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (12,'GESTIONAR_PRECIOS','Administrar precios');

INSERT INTO permisos (id_permiso,nombre_permiso,descripcion) VALUES (13,'GESTIONAR_PROMOCIONES','Administrar promociones');

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,2);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,3);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,4);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,5);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,6);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,7);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,8);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,9);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,10);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,11);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,12);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (1,13);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,2);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,3);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,4);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,5);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,6);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,7);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,8);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,9);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,10);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,11);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,12);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (2,13);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (3,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (3,7);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (4,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (4,8);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (5,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (5,4);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (5,5);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (5,6);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (6,1);

INSERT INTO rol_permiso (id_rol,id_permiso) VALUES (6,9);

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (1,1,'2026-10-05','2026-10-11','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (2,1,'2026-10-12','2026-10-18','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (3,1,'2026-10-19','2026-10-25','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (4,1,'2026-10-26','2026-11-01','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (5,1,'2026-11-02','2026-11-08','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (6,1,'2026-11-09','2026-11-15','FINALIZADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (7,1,'2026-11-16','2026-11-22','PUBLICADA');

INSERT INTO carteleras (id_cartelera,id_sucursal,fecha_inicio,fecha_fin,estado) VALUES (8,1,'2026-11-23','2026-11-29','PUBLICADA');

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,1);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,2);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,3);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,4);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,5);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,6);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (1,7);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,8);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,9);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,10);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,11);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,12);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,13);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (2,14);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,15);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,16);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,17);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,18);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,19);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,20);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (3,21);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,22);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,23);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,24);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,25);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,26);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,27);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (4,28);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,29);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,30);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,31);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,32);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,33);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,34);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (5,35);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,36);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,37);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,38);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,39);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,40);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,41);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (6,42);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,43);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,44);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,45);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,46);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,47);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,48);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (7,49);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,50);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,1);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,2);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,3);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,4);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,5);

INSERT INTO cartelera_pelicula (id_cartelera,id_pelicula) VALUES (8,6);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (1,1,1,1,'2026-10-05 13:00:00','2026-10-05 15:42:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (2,1,2,2,'2026-10-06 16:00:00','2026-10-06 19:15:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (3,1,3,3,'2026-10-07 19:00:00','2026-10-07 21:52:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (4,1,4,4,'2026-10-08 13:00:00','2026-10-08 16:42:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (5,1,5,5,'2026-10-09 16:00:00','2026-10-09 17:56:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (6,1,6,6,'2026-10-10 19:00:00','2026-10-10 22:35:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (7,1,7,1,'2026-10-11 13:00:00','2026-10-11 16:18:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (8,2,8,2,'2026-10-12 16:00:00','2026-10-12 18:54:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (9,2,9,3,'2026-10-13 19:00:00','2026-10-13 22:18:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (10,2,10,4,'2026-10-14 13:00:00','2026-10-14 15:39:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (11,2,11,5,'2026-10-15 16:00:00','2026-10-15 18:42:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (12,2,12,6,'2026-10-16 19:00:00','2026-10-16 21:48:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (13,2,13,1,'2026-10-17 13:00:00','2026-10-17 16:19:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (14,2,14,2,'2026-10-18 16:00:00','2026-10-18 19:41:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (15,3,15,3,'2026-10-19 19:00:00','2026-10-19 21:24:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (16,3,16,4,'2026-10-20 13:00:00','2026-10-20 15:36:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (17,3,17,5,'2026-10-21 16:00:00','2026-10-21 18:45:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (18,3,18,6,'2026-10-22 19:00:00','2026-10-22 21:33:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (19,3,19,1,'2026-10-23 13:00:00','2026-10-23 15:27:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (20,3,20,2,'2026-10-24 16:00:00','2026-10-24 18:18:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (21,3,21,3,'2026-10-25 19:00:00','2026-10-25 22:09:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (22,4,22,4,'2026-10-26 13:00:00','2026-10-26 16:09:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (23,4,23,5,'2026-10-27 16:00:00','2026-10-27 19:29:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (24,4,24,6,'2026-10-28 19:00:00','2026-10-28 21:25:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (25,4,25,1,'2026-10-29 13:00:00','2026-10-29 15:32:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (26,4,26,2,'2026-10-30 16:00:00','2026-10-30 18:06:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (27,4,27,3,'2026-10-31 19:00:00','2026-10-31 21:30:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (28,4,28,4,'2026-11-01 13:00:00','2026-11-01 15:51:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (29,5,29,5,'2026-11-02 16:00:00','2026-11-02 18:55:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (30,5,30,6,'2026-11-03 19:00:00','2026-11-03 20:48:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (31,5,31,1,'2026-11-04 13:00:00','2026-11-04 15:16:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (32,5,32,2,'2026-11-05 16:00:00','2026-11-05 18:17:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (33,5,33,3,'2026-11-06 19:00:00','2026-11-06 21:47:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (34,5,34,4,'2026-11-07 13:00:00','2026-11-07 15:13:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (35,5,35,5,'2026-11-08 16:00:00','2026-11-08 17:58:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (36,6,36,6,'2026-11-09 19:00:00','2026-11-09 21:05:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (37,6,37,1,'2026-11-10 13:00:00','2026-11-10 15:11:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (38,6,38,2,'2026-11-11 16:00:00','2026-11-11 17:56:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (39,6,39,3,'2026-11-12 19:00:00','2026-11-12 20:41:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (40,6,40,4,'2026-11-13 13:00:00','2026-11-13 14:55:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (41,6,41,5,'2026-11-14 16:00:00','2026-11-14 18:03:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (42,6,42,6,'2026-11-15 19:00:00','2026-11-15 21:08:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (43,7,43,1,'2026-11-16 13:00:00','2026-11-16 15:22:00','FINALIZADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (44,7,44,2,'2026-11-17 16:00:00','2026-11-17 18:55:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (45,7,45,3,'2026-11-18 19:00:00','2026-11-18 21:18:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (46,7,46,4,'2026-11-19 13:00:00','2026-11-19 15:35:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (47,7,47,5,'2026-11-20 16:00:00','2026-11-20 18:06:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (48,7,48,6,'2026-11-21 19:00:00','2026-11-21 21:54:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (49,7,49,1,'2026-11-22 13:00:00','2026-11-22 14:59:00','PROGRAMADA',9);

INSERT INTO funciones_cine (id_funcion,id_cartelera,id_pelicula,id_sala,fecha_inicio,fecha_fin,estado,creada_por) VALUES (50,8,50,2,'2026-11-23 16:00:00','2026-11-23 18:28:00','PROGRAMADA',9);

INSERT INTO precios_boletos (id_precio_boleto,id_sucursal,nombre_precio,cantidad,fecha_inicio) VALUES (1,1,'General',70,'2026-01-01');

INSERT INTO precios_boletos (id_precio_boleto,id_sucursal,nombre_precio,cantidad,fecha_inicio) VALUES (2,1,'Estudiante',50,'2026-01-01');

INSERT INTO precios_boletos (id_precio_boleto,id_sucursal,nombre_precio,cantidad,fecha_inicio) VALUES (3,1,'Adulto mayor',50,'2026-01-01');

INSERT INTO precios_boletos (id_precio_boleto,id_sucursal,nombre_precio,cantidad,fecha_inicio) VALUES (4,1,'Infantil',50,'2026-01-01');

INSERT INTO promociones (id_promocion,nombre_promocion,descripcion,tipo_descuento,valor_descuento,fecha_inicio,fecha_fin,texto_condiciones,creada_por) VALUES (1,'Martes cultural','Promoción ficticia para pruebas Aperture','PORCENTAJE',15,'2026-10-01 00:00:00','2027-02-28 23:59:59','Solo datos de demostración',2);

INSERT INTO promocion_sucursal (id_promocion,id_sucursal) VALUES (1,1);

INSERT INTO promociones (id_promocion,nombre_promocion,descripcion,tipo_descuento,valor_descuento,fecha_inicio,fecha_fin,texto_condiciones,creada_por) VALUES (2,'Combo familiar','Promoción ficticia para pruebas Aperture','CANTIDAD_FIJA',20,'2026-10-01 00:00:00','2027-02-28 23:59:59','Solo datos de demostración',2);

INSERT INTO promocion_sucursal (id_promocion,id_sucursal) VALUES (2,1);

INSERT INTO promociones (id_promocion,nombre_promocion,descripcion,tipo_descuento,valor_descuento,fecha_inicio,fecha_fin,texto_condiciones,creada_por) VALUES (3,'Ciclo de clásicos','Promoción ficticia para pruebas Aperture','PORCENTAJE',10,'2026-10-01 00:00:00','2027-02-28 23:59:59','Solo datos de demostración',2);

INSERT INTO promocion_sucursal (id_promocion,id_sucursal) VALUES (3,1);

INSERT INTO promociones (id_promocion,nombre_promocion,descripcion,tipo_descuento,valor_descuento,fecha_inicio,fecha_fin,texto_condiciones,creada_por) VALUES (4,'Dulcería especial','Promoción ficticia para pruebas Aperture','PORCENTAJE',5,'2026-10-01 00:00:00','2027-02-28 23:59:59','Solo datos de demostración',2);

INSERT INTO promocion_sucursal (id_promocion,id_sucursal) VALUES (4,1);

INSERT INTO promociones (id_promocion,nombre_promocion,descripcion,tipo_descuento,valor_descuento,fecha_inicio,fecha_fin,texto_condiciones,creada_por) VALUES (5,'Promoción estudiantes','Promoción ficticia para pruebas Aperture','CANTIDAD_FIJA',10,'2026-10-01 00:00:00','2027-02-28 23:59:59','Solo datos de demostración',2);

INSERT INTO promocion_sucursal (id_promocion,id_sucursal) VALUES (5,1);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (1,'Palomitas chicas','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,1,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (1,1,1,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (2,'Palomitas medianas','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,2,60,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (2,1,2,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (3,'Palomitas grandes','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,3,75,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (3,1,3,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (4,'Palomitas mantequilla','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,4,70,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (4,1,4,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (5,'Palomitas caramelo','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,5,80,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (5,1,5,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (6,'Refresco cola 355 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,6,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (6,1,6,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (7,'Refresco cola 600 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,7,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (7,1,7,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (8,'Refresco naranja 600 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,8,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (8,1,8,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (9,'Refresco limón 600 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,9,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (9,1,9,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (10,'Agua natural 600 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,10,30,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (10,1,10,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (11,'Agua mineral 600 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,11,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (11,1,11,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (12,'Jugo de manzana 355 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,12,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (12,1,12,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (13,'Té helado 500 ml','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,13,40,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (13,1,13,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (14,'Café americano','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,14,40,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (14,1,14,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (15,'Capuchino','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,15,55,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (15,1,15,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (16,'Chocolate caliente','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,16,50,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (16,1,16,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (17,'Nachos con queso','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,17,75,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (17,1,17,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (18,'Hot dog clásico','Producto genérico de prueba Aperture','ALIMENTOS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,18,65,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (18,1,18,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (19,'Hot dog especial','Producto genérico de prueba Aperture','ALIMENTOS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,19,80,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (19,1,19,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (20,'Pretzel','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,20,55,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (20,1,20,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (21,'Papas fritas','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,21,60,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (21,1,21,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (22,'Papas chips','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,22,40,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (22,1,22,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (23,'Cacahuates','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,23,30,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (23,1,23,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (24,'Gomitas surtidas','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,24,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (24,1,24,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (25,'Chocolates surtidos','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,25,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (25,1,25,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (26,'Barra de chocolate','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,26,30,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (26,1,26,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (27,'Caramelos','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,27,25,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (27,1,27,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (28,'Paleta de dulce','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,28,20,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (28,1,28,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (29,'Galletas','Producto genérico de prueba Aperture','DULCES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,29,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (29,1,29,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (30,'Brownie','Producto genérico de prueba Aperture','POSTRES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,30,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (30,1,30,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (31,'Muffin','Producto genérico de prueba Aperture','POSTRES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,31,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (31,1,31,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (32,'Helado individual','Producto genérico de prueba Aperture','POSTRES','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,32,55,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (32,1,32,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (33,'Sandwich','Producto genérico de prueba Aperture','ALIMENTOS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,33,70,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (33,1,33,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (34,'Pizza individual','Producto genérico de prueba Aperture','ALIMENTOS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,34,90,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (34,1,34,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (35,'Quesadilla','Producto genérico de prueba Aperture','ALIMENTOS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,35,60,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (35,1,35,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (36,'Bebida de frutas','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,36,50,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (36,1,36,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (37,'Limonada','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,37,45,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (37,1,37,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (38,'Agua saborizada','Producto genérico de prueba Aperture','BEBIDAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,38,35,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (38,1,38,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (39,'Barra de granola','Producto genérico de prueba Aperture','BOTANAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,39,30,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (39,1,39,0,10);

INSERT INTO productos (id_producto,nombre_producto,descripcion,categoria,unidad_medida) VALUES (40,'Palomitas mixtas','Producto genérico de prueba Aperture','PALOMITAS','PIEZA');

INSERT INTO precios_dulceria (id_sucursal,id_producto,precio,fecha_inicio) VALUES (1,40,85,'2026-01-01');

INSERT INTO existencias (id_existencia,id_sucursal,id_producto,cantidad_actual,cantidad_minima) VALUES (40,1,40,0,10);

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (1,'Combo clásico','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (1,2,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (1,7,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,1,95,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (2,'Combo grande','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (2,3,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (2,7,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,2,110,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (3,'Combo doble','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (3,3,2);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (3,7,2);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,3,210,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (4,'Combo nachos','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (4,17,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (4,7,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,4,105,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (5,'Combo dulce','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (5,2,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (5,24,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,5,85,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (6,'Combo familiar','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (6,3,2);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (6,7,4);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,6,285,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (7,'Combo hot dog','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (7,18,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (7,7,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,7,95,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (8,'Combo café','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (8,14,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (8,30,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,8,75,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (9,'Combo infantil','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (9,1,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (9,12,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (9,28,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,9,85,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (10,'Combo premium','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (10,5,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (10,15,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,10,115,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (11,'Combo pizza','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (11,34,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (11,7,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,11,125,'2026-01-01');

INSERT INTO combos (id_combo,nombre_combo,descripcion) VALUES (12,'Combo botana','Combo ficticio de demostración');

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (12,21,1);

INSERT INTO combo_productos (id_combo,id_producto,cantidad) VALUES (12,10,1);

INSERT INTO precios_dulceria (id_sucursal,id_combo,precio,fecha_inicio) VALUES (1,12,80,'2026-01-01');

INSERT INTO promocion_producto (id_promocion,id_producto,id_combo) VALUES (2,NULL,6);

INSERT INTO promocion_producto (id_promocion,id_producto,id_combo) VALUES (4,24,NULL);

INSERT INTO promocion_producto (id_promocion,id_producto,id_combo) VALUES (4,NULL,5);

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (1,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (1,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (2,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (2,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (3,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (3,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (4,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (4,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (5,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (5,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (6,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (6,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (7,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (7,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (8,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (8,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (9,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (9,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (10,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (10,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (11,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (11,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (12,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (12,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (13,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (13,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (14,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (14,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (15,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (15,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (16,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (16,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (17,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (17,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (18,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (18,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (19,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (19,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (20,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (20,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (21,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (21,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (22,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (22,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (23,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (23,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (24,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (24,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (25,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (25,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (26,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (26,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (27,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (27,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (28,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (28,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (29,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (29,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (30,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (30,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (31,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (31,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (32,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (32,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (33,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (33,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (34,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (34,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (35,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (35,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (36,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (36,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (37,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (37,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (38,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (38,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (39,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (39,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (40,10,'ENTRADA',80,'Carga inicial de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (40,13,'ENTRADA',20,'Reposición de prueba');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (1,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (2,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (3,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (4,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (5,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (6,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (7,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (8,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (9,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (10,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (11,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (12,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (13,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (14,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (15,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (16,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (17,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (18,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (19,10,'SALIDA',3,'Merma simulada');

INSERT INTO movimientos_inventario (id_existencia,id_usuario,tipo_movimiento,cantidad,motivo) VALUES (20,10,'SALIDA',3,'Merma simulada');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (1,1,4,'TAQUILLA','2026-10-05 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (2,1,5,'TAQUILLA','2026-10-06 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (3,1,3,'TAQUILLA','2026-10-07 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (4,1,4,'TAQUILLA','2026-10-08 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (5,1,5,'TAQUILLA','2026-10-09 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (6,1,3,'TAQUILLA','2026-10-10 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (7,1,4,'TAQUILLA','2026-10-11 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (8,1,5,'TAQUILLA','2026-10-12 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (9,1,3,'TAQUILLA','2026-10-13 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (10,1,4,'TAQUILLA','2026-10-14 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (11,1,5,'TAQUILLA','2026-10-15 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (12,1,3,'TAQUILLA','2026-10-16 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (13,1,4,'TAQUILLA','2026-10-17 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (14,1,5,'TAQUILLA','2026-10-18 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (15,1,3,'TAQUILLA','2026-10-19 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (16,1,4,'TAQUILLA','2026-10-20 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (17,1,5,'TAQUILLA','2026-10-21 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (18,1,3,'TAQUILLA','2026-10-22 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (19,1,4,'TAQUILLA','2026-10-23 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (20,1,5,'TAQUILLA','2026-10-24 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (21,1,3,'TAQUILLA','2026-10-25 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (22,1,4,'TAQUILLA','2026-10-26 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (23,1,5,'TAQUILLA','2026-10-27 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (24,1,3,'TAQUILLA','2026-10-28 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (25,1,4,'TAQUILLA','2026-10-29 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (26,1,5,'TAQUILLA','2026-10-30 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (27,1,3,'TAQUILLA','2026-10-31 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (28,1,4,'TAQUILLA','2026-11-01 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (29,1,5,'TAQUILLA','2026-11-02 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (30,1,3,'TAQUILLA','2026-11-03 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (31,1,4,'TAQUILLA','2026-11-04 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (32,1,5,'TAQUILLA','2026-11-05 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (33,1,3,'TAQUILLA','2026-11-06 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (34,1,4,'TAQUILLA','2026-11-07 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (35,1,5,'TAQUILLA','2026-11-08 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (36,1,3,'TAQUILLA','2026-10-05 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (37,1,4,'TAQUILLA','2026-10-06 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (38,1,5,'TAQUILLA','2026-10-07 12:00:00',140,0,140,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (39,1,3,'TAQUILLA','2026-10-08 12:00:00',100,0,100,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (40,1,4,'TAQUILLA','2026-10-09 12:00:00',140,0,140,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (41,1,5,'TAQUILLA','2026-10-10 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (42,1,3,'TAQUILLA','2026-10-11 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (43,1,4,'TAQUILLA','2026-10-12 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (44,1,5,'TAQUILLA','2026-10-13 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (45,1,3,'TAQUILLA','2026-10-14 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (46,1,4,'TAQUILLA','2026-10-15 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (47,1,5,'TAQUILLA','2026-10-16 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (48,1,3,'TAQUILLA','2026-10-17 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (49,1,4,'TAQUILLA','2026-10-18 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (50,1,5,'TAQUILLA','2026-10-19 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (51,1,3,'TAQUILLA','2026-10-20 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (52,1,4,'TAQUILLA','2026-10-21 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (53,1,5,'TAQUILLA','2026-10-22 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (54,1,3,'TAQUILLA','2026-10-23 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (55,1,4,'TAQUILLA','2026-10-24 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (56,1,5,'TAQUILLA','2026-10-25 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (57,1,3,'TAQUILLA','2026-10-26 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (58,1,4,'TAQUILLA','2026-10-27 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (59,1,5,'TAQUILLA','2026-10-28 12:00:00',70,0,70,'TRANSFERENCIA','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (60,1,3,'TAQUILLA','2026-10-29 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (61,1,7,'DULCERIA','2026-10-05 12:00:00',45,0,45,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (61,1,'Palomitas chicas',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (62,1,8,'DULCERIA','2026-10-06 12:00:00',60,0,60,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (62,2,'Palomitas medianas',1,60,0,60);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (63,1,6,'DULCERIA','2026-10-07 12:00:00',75,0,75,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (63,3,'Palomitas grandes',1,75,0,75);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (64,1,7,'DULCERIA','2026-10-08 12:00:00',70,0,70,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (64,4,'Palomitas mantequilla',1,70,0,70);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (65,1,8,'DULCERIA','2026-10-09 12:00:00',80,0,80,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (65,5,'Palomitas caramelo',1,80,0,80);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (66,1,6,'DULCERIA','2026-10-10 12:00:00',35,0,35,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (66,6,'Refresco cola 355 ml',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (67,1,7,'DULCERIA','2026-10-11 12:00:00',45,0,45,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (67,7,'Refresco cola 600 ml',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (68,1,8,'DULCERIA','2026-10-12 12:00:00',45,0,45,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (68,8,'Refresco naranja 600 ml',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (69,1,6,'DULCERIA','2026-10-13 12:00:00',45,0,45,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (69,9,'Refresco limón 600 ml',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (70,1,7,'DULCERIA','2026-10-14 12:00:00',30,0,30,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (70,10,'Agua natural 600 ml',1,30,0,30);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (71,1,8,'DULCERIA','2026-10-15 12:00:00',35,0,35,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (71,11,'Agua mineral 600 ml',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (72,1,6,'DULCERIA','2026-10-16 12:00:00',35,0,35,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (72,12,'Jugo de manzana 355 ml',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (73,1,7,'DULCERIA','2026-10-17 12:00:00',40,0,40,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (73,13,'Té helado 500 ml',1,40,0,40);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (74,1,8,'DULCERIA','2026-10-18 12:00:00',40,0,40,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (74,14,'Café americano',1,40,0,40);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (75,1,6,'DULCERIA','2026-10-19 12:00:00',55,0,55,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (75,15,'Capuchino',1,55,0,55);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (76,1,7,'DULCERIA','2026-10-20 12:00:00',50,0,50,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (76,16,'Chocolate caliente',1,50,0,50);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (77,1,8,'DULCERIA','2026-10-21 12:00:00',75,0,75,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (77,17,'Nachos con queso',1,75,0,75);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (78,1,6,'DULCERIA','2026-10-22 12:00:00',65,0,65,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (78,18,'Hot dog clásico',1,65,0,65);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (79,1,7,'DULCERIA','2026-10-23 12:00:00',80,0,80,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (79,19,'Hot dog especial',1,80,0,80);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (80,1,8,'DULCERIA','2026-10-24 12:00:00',55,0,55,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (80,20,'Pretzel',1,55,0,55);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (81,1,6,'DULCERIA','2026-10-25 12:00:00',60,0,60,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (81,21,'Papas fritas',1,60,0,60);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (82,1,7,'DULCERIA','2026-10-26 12:00:00',40,0,40,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (82,22,'Papas chips',1,40,0,40);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (83,1,8,'DULCERIA','2026-10-27 12:00:00',30,0,30,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (83,23,'Cacahuates',1,30,0,30);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (84,1,6,'DULCERIA','2026-10-28 12:00:00',35,0,35,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (84,24,'Gomitas surtidas',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (85,1,7,'DULCERIA','2026-10-29 12:00:00',45,0,45,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (85,25,'Chocolates surtidos',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (86,1,8,'DULCERIA','2026-10-30 12:00:00',30,0,30,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (86,26,'Barra de chocolate',1,30,0,30);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (87,1,6,'DULCERIA','2026-10-31 12:00:00',25,0,25,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (87,27,'Caramelos',1,25,0,25);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (88,1,7,'DULCERIA','2026-11-01 12:00:00',20,0,20,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (88,28,'Paleta de dulce',1,20,0,20);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (89,1,8,'DULCERIA','2026-11-02 12:00:00',35,0,35,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (89,29,'Galletas',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (90,1,6,'DULCERIA','2026-11-03 12:00:00',45,0,45,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (90,30,'Brownie',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (91,1,7,'DULCERIA','2026-11-04 12:00:00',45,0,45,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (91,31,'Muffin',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (92,1,8,'DULCERIA','2026-11-05 12:00:00',55,0,55,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (92,32,'Helado individual',1,55,0,55);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (93,1,6,'DULCERIA','2026-11-06 12:00:00',70,0,70,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (93,33,'Sandwich',1,70,0,70);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (94,1,7,'DULCERIA','2026-11-07 12:00:00',90,0,90,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (94,34,'Pizza individual',1,90,0,90);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (95,1,8,'DULCERIA','2026-11-08 12:00:00',60,0,60,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (95,35,'Quesadilla',1,60,0,60);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (96,1,6,'DULCERIA','2026-11-09 12:00:00',50,0,50,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (96,36,'Bebida de frutas',1,50,0,50);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (97,1,7,'DULCERIA','2026-11-10 12:00:00',45,0,45,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (97,37,'Limonada',1,45,0,45);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (98,1,8,'DULCERIA','2026-11-11 12:00:00',35,0,35,'TRANSFERENCIA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (98,38,'Agua saborizada',1,35,0,35);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (99,1,6,'DULCERIA','2026-11-12 12:00:00',30,0,30,'EFECTIVO','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (99,39,'Barra de granola',1,30,0,30);

INSERT INTO ventas (id_venta,id_sucursal,id_usuario,tipo_venta,fecha_venta,subtotal,descuento,total,metodo_pago,estado) VALUES (100,1,7,'DULCERIA','2026-11-13 12:00:00',85,0,85,'TARJETA','COMPLETADA');

INSERT INTO detalles_venta (id_venta,id_producto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (100,40,'Palomitas mixtas',1,85,0,85);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (1,1,1,1,1,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (1,1,'Boleto función 1',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (2,1,2,1,1,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (1,2,'Boleto función 1',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (3,2,25,1,2,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (2,3,'Boleto función 2',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (4,2,26,1,2,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (2,4,'Boleto función 2',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (5,3,53,2,3,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (3,5,'Boleto función 3',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (6,3,54,2,3,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (3,6,'Boleto función 3',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (7,4,85,1,4,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (4,7,'Boleto función 4',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (8,4,86,1,4,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (4,8,'Boleto función 4',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (9,5,109,1,5,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (5,9,'Boleto función 5',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (10,5,110,1,5,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (5,10,'Boleto función 5',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (11,6,145,2,6,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (6,11,'Boleto función 6',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (12,6,146,2,6,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (6,12,'Boleto función 6',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (13,7,1,1,7,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (7,13,'Boleto función 7',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (14,7,2,1,7,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (7,14,'Boleto función 7',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (15,8,25,1,8,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (8,15,'Boleto función 8',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (16,8,26,1,8,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (8,16,'Boleto función 8',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (17,9,53,2,9,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (9,17,'Boleto función 9',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (18,9,54,2,9,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (9,18,'Boleto función 9',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (19,10,85,1,10,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (10,19,'Boleto función 10',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (20,10,86,1,10,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (10,20,'Boleto función 10',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (21,11,109,1,11,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (11,21,'Boleto función 11',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (22,11,110,1,11,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (11,22,'Boleto función 11',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (23,12,145,2,12,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (12,23,'Boleto función 12',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (24,12,146,2,12,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (12,24,'Boleto función 12',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (25,13,1,1,13,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (13,25,'Boleto función 13',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (26,13,2,1,13,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (13,26,'Boleto función 13',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (27,14,25,1,14,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (14,27,'Boleto función 14',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (28,14,26,1,14,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (14,28,'Boleto función 14',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (29,15,53,2,15,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (15,29,'Boleto función 15',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (30,15,54,2,15,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (15,30,'Boleto función 15',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (31,16,85,1,16,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (16,31,'Boleto función 16',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (32,16,86,1,16,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (16,32,'Boleto función 16',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (33,17,109,1,17,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (17,33,'Boleto función 17',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (34,17,110,1,17,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (17,34,'Boleto función 17',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (35,18,145,2,18,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (18,35,'Boleto función 18',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (36,18,146,2,18,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (18,36,'Boleto función 18',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (37,19,1,1,19,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (19,37,'Boleto función 19',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (38,19,2,1,19,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (19,38,'Boleto función 19',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (39,20,25,1,20,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (20,39,'Boleto función 20',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (40,20,26,1,20,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (20,40,'Boleto función 20',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (41,21,53,2,21,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (21,41,'Boleto función 21',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (42,21,54,2,21,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (21,42,'Boleto función 21',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (43,22,85,1,22,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (22,43,'Boleto función 22',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (44,22,86,1,22,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (22,44,'Boleto función 22',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (45,23,109,1,23,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (23,45,'Boleto función 23',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (46,23,110,1,23,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (23,46,'Boleto función 23',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (47,24,145,2,24,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (24,47,'Boleto función 24',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (48,24,146,2,24,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (24,48,'Boleto función 24',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (49,25,1,1,25,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (25,49,'Boleto función 25',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (50,25,2,1,25,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (25,50,'Boleto función 25',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (51,26,25,1,26,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (26,51,'Boleto función 26',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (52,26,26,1,26,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (26,52,'Boleto función 26',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (53,27,53,2,27,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (27,53,'Boleto función 27',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (54,27,54,2,27,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (27,54,'Boleto función 27',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (55,28,85,1,28,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (28,55,'Boleto función 28',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (56,28,86,1,28,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (28,56,'Boleto función 28',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (57,29,109,1,29,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (29,57,'Boleto función 29',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (58,29,110,1,29,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (29,58,'Boleto función 29',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (59,30,145,2,30,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (30,59,'Boleto función 30',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (60,30,146,2,30,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (30,60,'Boleto función 30',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (61,31,1,1,31,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (31,61,'Boleto función 31',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (62,31,2,1,31,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (31,62,'Boleto función 31',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (63,32,25,1,32,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (32,63,'Boleto función 32',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (64,32,26,1,32,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (32,64,'Boleto función 32',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (65,33,53,2,33,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (33,65,'Boleto función 33',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (66,33,54,2,33,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (33,66,'Boleto función 33',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (67,34,85,1,34,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (34,67,'Boleto función 34',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (68,34,86,1,34,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (34,68,'Boleto función 34',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (69,35,109,1,35,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (35,69,'Boleto función 35',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (70,35,110,1,35,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (35,70,'Boleto función 35',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (71,1,3,2,36,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (36,71,'Boleto función 1',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (72,1,4,2,36,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (36,72,'Boleto función 1',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (73,2,27,1,37,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (37,73,'Boleto función 2',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (74,2,28,1,37,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (37,74,'Boleto función 2',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (75,3,55,1,38,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (38,75,'Boleto función 3',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (76,3,56,1,38,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (38,76,'Boleto función 3',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (77,4,87,2,39,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (39,77,'Boleto función 4',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (78,4,88,2,39,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (39,78,'Boleto función 4',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (79,5,111,1,40,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (40,79,'Boleto función 5',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (80,5,112,1,40,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (40,80,'Boleto función 5',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (81,6,147,1,41,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (41,81,'Boleto función 6',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (82,7,3,2,42,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (42,82,'Boleto función 7',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (83,8,27,1,43,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (43,83,'Boleto función 8',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (84,9,55,1,44,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (44,84,'Boleto función 9',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (85,10,87,2,45,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (45,85,'Boleto función 10',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (86,11,111,1,46,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (46,86,'Boleto función 11',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (87,12,147,1,47,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (47,87,'Boleto función 12',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (88,13,3,2,48,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (48,88,'Boleto función 13',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (89,14,27,1,49,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (49,89,'Boleto función 14',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (90,15,55,1,50,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (50,90,'Boleto función 15',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (91,16,87,2,51,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (51,91,'Boleto función 16',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (92,17,111,1,52,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (52,92,'Boleto función 17',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (93,18,147,1,53,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (53,93,'Boleto función 18',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (94,19,3,2,54,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (54,94,'Boleto función 19',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (95,20,27,1,55,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (55,95,'Boleto función 20',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (96,21,55,1,56,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (56,96,'Boleto función 21',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (97,22,87,2,57,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (57,97,'Boleto función 22',1,50,0,50);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (98,23,111,1,58,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (58,98,'Boleto función 23',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (99,24,147,1,59,70,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (59,99,'Boleto función 24',1,70,0,70);

INSERT INTO boletos (id_boleto,id_funcion,id_asiento,id_precio_boleto,id_venta,precio_pagado,estado) VALUES (100,25,3,2,60,50,'USADO');

INSERT INTO detalles_venta (id_venta,id_boleto,descripcion,cantidad,precio_unitario,descuento,total_linea) VALUES (60,100,'Boleto función 25',1,50,0,50);

COMMIT;



-- RESUMEN DE CARGA Y VALIDACIONES

SELECT 'sucursales' AS tabla, COUNT(*) AS registros FROM sucursales;

SELECT 'salas' AS tabla, COUNT(*) AS registros FROM salas;

SELECT 'asientos' AS tabla, COUNT(*) AS registros FROM asientos;

SELECT 'peliculas' AS tabla, COUNT(*) AS registros FROM peliculas;

SELECT 'empleados' AS tabla, COUNT(*) AS registros FROM empleados;

SELECT 'usuarios' AS tabla, COUNT(*) AS registros FROM usuarios;

SELECT 'roles' AS tabla, COUNT(*) AS registros FROM roles;

SELECT 'permisos' AS tabla, COUNT(*) AS registros FROM permisos;

SELECT 'carteleras' AS tabla, COUNT(*) AS registros FROM carteleras;

SELECT 'cartelera_pelicula' AS tabla, COUNT(*) AS registros FROM cartelera_pelicula;

SELECT 'funciones_cine' AS tabla, COUNT(*) AS registros FROM funciones_cine;

SELECT 'productos' AS tabla, COUNT(*) AS registros FROM productos;

SELECT 'combos' AS tabla, COUNT(*) AS registros FROM combos;

SELECT 'combo_productos' AS tabla, COUNT(*) AS registros FROM combo_productos;

SELECT 'ventas' AS tabla, COUNT(*) AS registros FROM ventas;

SELECT 'boletos' AS tabla, COUNT(*) AS registros FROM boletos;

SELECT 'detalles_venta' AS tabla, COUNT(*) AS registros FROM detalles_venta;

SELECT 'existencias' AS tabla, COUNT(*) AS registros FROM existencias;

SELECT 'movimientos_inventario' AS tabla, COUNT(*) AS registros FROM movimientos_inventario;

SELECT COUNT(*) AS ventas_con_total_incorrecto FROM ventas WHERE total <> subtotal-descuento;

SELECT COUNT(*) AS ventas_sin_detalle FROM ventas v WHERE NOT EXISTS (SELECT 1 FROM detalles_venta d WHERE d.id_venta=v.id_venta);

SELECT COUNT(*) AS ventas_con_detalle_inconsistente FROM ventas v WHERE v.subtotal <> (SELECT COALESCE(SUM(d.cantidad*d.precio_unitario),0) FROM detalles_venta d WHERE d.id_venta=v.id_venta);

SELECT COUNT(*) AS boletos_con_sala_incorrecta FROM boletos b JOIN funciones_cine f ON f.id_funcion=b.id_funcion JOIN asientos a ON a.id_asiento=b.id_asiento WHERE a.id_sala<>f.id_sala;

SELECT COUNT(*) AS asientos_duplicados_vigentes FROM (SELECT id_funcion,id_asiento FROM boletos WHERE estado IN ('VENDIDO','USADO') GROUP BY id_funcion,id_asiento HAVING COUNT(*)>1) x;

SELECT COUNT(*) AS existencias_negativas FROM existencias WHERE cantidad_actual<0;

SELECT COUNT(*) AS funciones_fuera_cartelera FROM funciones_cine f JOIN carteleras c ON c.id_cartelera=f.id_cartelera WHERE DATE(f.fecha_inicio) NOT BETWEEN c.fecha_inicio AND c.fecha_fin;

-- Comprobaciones adicionales: todas deben devolver 0
SELECT COUNT(*) AS salas_con_capacidad_incorrecta FROM salas s WHERE s.capacidad <> (SELECT COUNT(*) FROM asientos a WHERE a.id_sala=s.id_sala);
SELECT COUNT(*) AS usuarios_inactivos FROM usuarios WHERE activo=0;
SELECT COUNT(*) AS boletos_sin_detalle FROM boletos b WHERE NOT EXISTS (SELECT 1 FROM detalles_venta d WHERE d.id_boleto=b.id_boleto);
SELECT COUNT(*) AS funciones_con_sucursal_incorrecta FROM funciones_cine f JOIN salas s ON s.id_sala=f.id_sala JOIN carteleras c ON c.id_cartelera=f.id_cartelera WHERE s.id_sucursal<>c.id_sucursal;
SELECT COUNT(*) AS funciones_solapadas FROM funciones_cine f JOIN funciones_cine g ON f.id_sala=g.id_sala AND f.id_funcion<g.id_funcion AND f.estado<>'CANCELADA' AND g.estado<>'CANCELADA' AND f.fecha_inicio<g.fecha_fin AND f.fecha_fin>g.fecha_inicio;
SELECT COUNT(*) AS ventas_con_detalles_distintos FROM ventas v WHERE ABS(v.total-(SELECT COALESCE(SUM(d.total_linea),0) FROM detalles_venta d WHERE d.id_venta=v.id_venta))>0.01;

-- RESUMEN PARA COMPROBACION EN WORKBENCH (solo lectura)
SELECT 'tablas' AS concepto, COUNT(*) AS total FROM information_schema.tables WHERE table_schema='aperture_entrega' AND table_type='BASE TABLE'
UNION ALL SELECT 'vistas', COUNT(*) FROM information_schema.views WHERE table_schema='aperture_entrega'
UNION ALL SELECT 'triggers', COUNT(*) FROM information_schema.triggers WHERE trigger_schema='aperture_entrega'
UNION ALL SELECT 'salas', COUNT(*) FROM salas
UNION ALL SELECT 'asientos', COUNT(*) FROM asientos
UNION ALL SELECT 'peliculas', COUNT(*) FROM peliculas
UNION ALL SELECT 'carteleras', COUNT(*) FROM carteleras
UNION ALL SELECT 'funciones', COUNT(*) FROM funciones_cine
UNION ALL SELECT 'empleados', COUNT(*) FROM empleados
UNION ALL SELECT 'usuarios', COUNT(*) FROM usuarios
UNION ALL SELECT 'ventas', COUNT(*) FROM ventas
UNION ALL SELECT 'boletos', COUNT(*) FROM boletos;

SELECT e.numero_empleado AS clave_personal, CONCAT_WS(' ',e.nombre_empleado,e.apellido_paterno,e.apellido_materno) AS empleado,
       u.nombre_usuario AS acceso, r.nombre_rol AS rol, u.activo
FROM empleados e JOIN usuarios u ON u.id_empleado=e.id_empleado
JOIN rol_usuario ru ON ru.id_usuario=u.id_usuario JOIN roles r ON r.id_rol=ru.id_rol
ORDER BY e.numero_empleado;
