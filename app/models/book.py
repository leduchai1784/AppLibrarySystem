from typing import Optional

from pydantic import BaseModel


class Book(BaseModel):
    id: str
    title: str
    author: str
    genre: str
    description: str

    # Optional fields (useful for client UI / inventory-aware recommendations)
    category: Optional[str] = None
    availableQuantity: Optional[float] = None
    available: Optional[float] = None
    quantity: Optional[float] = None
    isAvailable: Optional[bool] = None

