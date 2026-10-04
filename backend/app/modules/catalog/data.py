from dataclasses import dataclass
from enum import StrEnum


class Distribution(StrEnum):
    FIXED = "fixed"
    ROTATING = "rotating"


class Frequency(StrEnum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    INTERVAL = "interval"


@dataclass(frozen=True, slots=True)
class TaskCategory:
    key: str
    name: str


@dataclass(frozen=True, slots=True)
class Activity:
    key: str
    name: str
    category_key: str
    estimated_duration_minutes: int
    effort: int
    mental_load: int


@dataclass(frozen=True, slots=True)
class Recurrence:
    frequency: Frequency
    weekdays: tuple[int, ...] = ()
    day_of_month: int | None = None
    interval_days: int | None = None


@dataclass(frozen=True, slots=True)
class TemplateTask:
    activity_key: str
    recurrence: Recurrence
    recurrence_label: str
    distribution: Distribution


@dataclass(frozen=True, slots=True)
class HouseholdTemplate:
    key: str
    name: str
    description: str
    tasks: tuple[TemplateTask, ...]


CATEGORIES: tuple[TaskCategory, ...] = (
    TaskCategory("food", "Alimentación"),
    TaskCategory("cleaning", "Limpieza"),
    TaskCategory("laundry", "Ropa"),
    TaskCategory("shopping", "Compras"),
    TaskCategory("waste", "Basura y reciclaje"),
    TaskCategory("garden", "Plantas y jardín"),
    TaskCategory("pets", "Mascotas"),
    TaskCategory("children", "Niñas y niños"),
    TaskCategory("care", "Cuidados"),
    TaskCategory("errands", "Trámites y cuentas"),
    TaskCategory("maintenance", "Mantenimiento"),
)

ACTIVITIES: tuple[Activity, ...] = (
    Activity("cook", "Cocinar", "food", 45, 3, 3),
    Activity("plan_meals", "Planificar el menú", "food", 20, 1, 4),
    Activity("wash_dishes", "Lavar los platos", "food", 20, 2, 1),
    Activity("clean_kitchen", "Limpiar la cocina", "cleaning", 30, 3, 1),
    Activity("bathroom_cleaning", "Limpiar el baño", "cleaning", 30, 4, 1),
    Activity("mop_floors", "Fregar suelos", "cleaning", 30, 4, 1),
    Activity("vacuum", "Pasar la aspiradora", "cleaning", 25, 3, 1),
    Activity("dust", "Quitar el polvo", "cleaning", 20, 2, 1),
    Activity("clean_windows", "Limpiar cristales", "cleaning", 40, 3, 1),
    Activity("change_sheets", "Cambiar las sábanas", "cleaning", 20, 2, 1),
    Activity("laundry_load", "Poner la lavadora", "laundry", 15, 2, 2),
    Activity("hang_laundry", "Tender la ropa", "laundry", 15, 2, 1),
    Activity("fold_laundry", "Doblar y guardar la ropa", "laundry", 20, 2, 1),
    Activity("ironing", "Planchar", "laundry", 40, 3, 1),
    Activity("weekly_shopping", "Compra semanal", "shopping", 60, 3, 4),
    Activity("restock_household", "Reponer productos de la casa", "shopping", 20, 2, 3),
    Activity("take_out_trash", "Sacar la basura", "waste", 5, 1, 1),
    Activity("recycling", "Separar y llevar el reciclaje", "waste", 15, 2, 2),
    Activity("water_plants", "Regar las plantas", "garden", 10, 1, 1),
    Activity("garden_care", "Cuidar el jardín", "garden", 45, 4, 2),
    Activity("dog_walk", "Pasear al perro", "pets", 30, 2, 1),
    Activity("feed_pets", "Dar de comer a las mascotas", "pets", 5, 1, 2),
    Activity("clean_litter", "Limpiar el arenero", "pets", 10, 2, 1),
    Activity("vet_appointments", "Llevar al veterinario", "pets", 90, 3, 4),
    Activity("school_run", "Llevar y recoger del colegio", "children", 40, 2, 3),
    Activity("homework_help", "Acompañar las tareas escolares", "children", 45, 2, 4),
    Activity("children_bath", "Bañar a niñas y niños", "children", 25, 3, 2),
    Activity("children_bedtime", "Acostar a niñas y niños", "children", 30, 2, 3),
    Activity("school_supplies", "Preparar mochilas y materiales", "children", 15, 1, 4),
    Activity("medication", "Organizar y dar medicamentos", "care", 10, 1, 5),
    Activity("medical_appointments", "Acompañar a citas médicas", "care", 120, 3, 5),
    Activity("personal_care", "Apoyar en el aseo personal", "care", 30, 4, 3),
    Activity("care_companionship", "Acompañar y supervisar", "care", 60, 2, 4),
    Activity("pay_bills", "Pagar las cuentas", "errands", 20, 1, 4),
    Activity("paperwork", "Trámites", "errands", 60, 2, 5),
    Activity("home_repairs", "Pequeñas reparaciones", "maintenance", 60, 4, 3),
    Activity("move_furniture", "Mover muebles", "maintenance", 30, 5, 1),
)

_DAILY = Recurrence(Frequency.DAILY)


def _weekly(*weekdays: int) -> Recurrence:
    return Recurrence(Frequency.WEEKLY, weekdays=weekdays)


def _monthly(day: int) -> Recurrence:
    return Recurrence(Frequency.MONTHLY, day_of_month=day)


def _task(
    activity_key: str, recurrence: Recurrence, label: str, distribution: Distribution
) -> TemplateTask:
    return TemplateTask(activity_key, recurrence, label, distribution)


ROTATING = Distribution.ROTATING
FIXED = Distribution.FIXED

TEMPLATES: tuple[HouseholdTemplate, ...] = (
    HouseholdTemplate(
        "family_with_children",
        "Familia con niñas o niños",
        "Rutinas de cocina, colegio, ropa y limpieza de una familia con hijas o hijos.",
        (
            _task("cook", _DAILY, "A diario", ROTATING),
            _task("plan_meals", _weekly(6), "Domingos", FIXED),
            _task("wash_dishes", _DAILY, "A diario", ROTATING),
            _task("clean_kitchen", _weekly(2, 5), "Miércoles y sábados", ROTATING),
            _task("bathroom_cleaning", _weekly(5), "Semanal", ROTATING),
            _task("vacuum", _weekly(1, 4), "Martes y viernes", ROTATING),
            _task("mop_floors", _weekly(5), "Semanal", ROTATING),
            _task("change_sheets", _weekly(6), "Semanal", ROTATING),
            _task("laundry_load", _weekly(0, 3), "2 veces por semana", ROTATING),
            _task("hang_laundry", _weekly(0, 3), "2 veces por semana", ROTATING),
            _task("fold_laundry", _weekly(1, 4), "2 veces por semana", ROTATING),
            _task("weekly_shopping", _weekly(5), "Sábados", FIXED),
            _task("take_out_trash", _weekly(0, 2, 4), "Lunes, miércoles y viernes", ROTATING),
            _task("school_run", _weekly(0, 1, 2, 3, 4), "De lunes a viernes", ROTATING),
            _task("homework_help", _weekly(0, 1, 2, 3), "De lunes a jueves", ROTATING),
            _task("children_bath", _DAILY, "A diario", ROTATING),
            _task("children_bedtime", _DAILY, "A diario", ROTATING),
            _task("school_supplies", _weekly(6), "Domingos", FIXED),
            _task("pay_bills", _monthly(5), "Mensual", FIXED),
        ),
    ),
    HouseholdTemplate(
        "shared_flat",
        "Piso compartido",
        "Zonas comunes, basura y compras compartidas entre compañeras y compañeros de piso.",
        (
            _task("clean_kitchen", _weekly(2, 6), "2 veces por semana", ROTATING),
            _task("wash_dishes", _DAILY, "A diario", ROTATING),
            _task("bathroom_cleaning", _weekly(5), "Semanal", ROTATING),
            _task("vacuum", _weekly(5), "Semanal", ROTATING),
            _task("mop_floors", _weekly(5), "Semanal", ROTATING),
            _task(
                "dust", Recurrence(Frequency.INTERVAL, interval_days=14), "Cada 2 semanas", ROTATING
            ),
            _task("take_out_trash", _weekly(0, 3), "2 veces por semana", ROTATING),
            _task("recycling", _weekly(6), "Domingos", ROTATING),
            _task("restock_household", _weekly(4), "Viernes", ROTATING),
            _task("weekly_shopping", _weekly(5), "Sábados", ROTATING),
            _task("water_plants", _weekly(1, 4), "2 veces por semana", ROTATING),
            _task("clean_windows", _monthly(15), "Mensual", ROTATING),
            _task("pay_bills", _monthly(5), "Mensual", FIXED),
            _task("home_repairs", _monthly(20), "Mensual", ROTATING),
        ),
    ),
    HouseholdTemplate(
        "couple",
        "Pareja",
        "Lo básico para repartir la casa entre dos personas.",
        (
            _task("cook", _DAILY, "A diario", ROTATING),
            _task("wash_dishes", _DAILY, "A diario", ROTATING),
            _task("bathroom_cleaning", _weekly(5), "Semanal", ROTATING),
            _task("vacuum", _weekly(5), "Semanal", ROTATING),
            _task("laundry_load", _weekly(0, 3), "2 veces por semana", ROTATING),
            _task("ironing", _weekly(6), "Domingos", ROTATING),
            _task("weekly_shopping", _weekly(5), "Sábados", ROTATING),
            _task("take_out_trash", _weekly(0, 3), "2 veces por semana", ROTATING),
            _task("change_sheets", _weekly(6), "Semanal", ROTATING),
            _task("pay_bills", _monthly(5), "Mensual", FIXED),
        ),
    ),
    HouseholdTemplate(
        "care",
        "Con personas a cuidado",
        "Cuidados diarios, medicación, citas y trámites de una persona que necesita apoyo.",
        (
            _task("medication", _DAILY, "A diario", FIXED),
            _task("personal_care", _DAILY, "A diario", ROTATING),
            _task("care_companionship", _DAILY, "A diario", ROTATING),
            _task("medical_appointments", _monthly(10), "Mensual", ROTATING),
            _task("cook", _DAILY, "A diario", ROTATING),
            _task("plan_meals", _weekly(6), "Domingos", FIXED),
            _task("restock_household", _weekly(4), "Viernes", ROTATING),
            _task("change_sheets", _weekly(2, 5), "2 veces por semana", ROTATING),
            _task("laundry_load", _weekly(0, 2, 4), "3 veces por semana", ROTATING),
            _task("bathroom_cleaning", _weekly(1, 4), "2 veces por semana", ROTATING),
            _task("paperwork", _monthly(1), "Mensual", FIXED),
            _task("pay_bills", _monthly(5), "Mensual", FIXED),
        ),
    ),
    HouseholdTemplate(
        "pets",
        "Vivo con mascotas",
        "Paseos, comida, higiene y veterinario de las mascotas de la casa.",
        (
            _task("dog_walk", _DAILY, "A diario", ROTATING),
            _task("feed_pets", _DAILY, "A diario", ROTATING),
            _task(
                "clean_litter",
                Recurrence(Frequency.INTERVAL, interval_days=2),
                "Cada 2 días",
                ROTATING,
            ),
            _task("vacuum", _weekly(2), "Semanal", ROTATING),
            _task("restock_household", _weekly(4), "Semanal", ROTATING),
            _task(
                "vet_appointments",
                Recurrence(Frequency.INTERVAL, interval_days=180),
                "Cada 6 meses",
                FIXED,
            ),
        ),
    ),
)

CATEGORIES_BY_KEY = {category.key: category for category in CATEGORIES}
ACTIVITIES_BY_KEY = {activity.key: activity for activity in ACTIVITIES}
TEMPLATES_BY_KEY = {template.key: template for template in TEMPLATES}
