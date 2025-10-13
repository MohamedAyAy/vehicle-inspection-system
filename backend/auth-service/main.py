"""
Authorization Service - Authentication & Token Management
Port: 8001
Database: auth_db
"""

from fastapi import FastAPI, HTTPException, Header, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, field_validator
import jwt
import os
from datetime import datetime, timedelta
from typing import Optional, AsyncGenerator
from contextlib import asynccontextmanager
import bcrypt
import logging
from dotenv import load_dotenv
import httpx

# SQLAlchemy imports
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base, Mapped, mapped_column
from sqlalchemy import String, Boolean, DateTime, select, func
from sqlalchemy.dialects.postgresql import UUID
import uuid

load_dotenv()

# ============= CONFIGURATION =============

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-super-secret-key-change-this-in-production")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
JWT_EXPIRATION_HOURS = int(os.getenv("JWT_EXPIRATION_HOURS", "24"))

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "azerty5027")
DB_NAME = os.getenv("DB_NAME_AUTH", "auth_db")

# For local development, use localhost instead of service names
LOGGING_SERVICE_URL = os.getenv("LOGGING_SERVICE_URL", "http://localhost:8005")

# SQLAlchemy Database URL
DATABASE_URL = f"postgresql+asyncpg://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# CORS Configuration
FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:3000")

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============= DATA MODELS =============
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    role: str = "customer"
    
    @field_validator("password")
    @classmethod
    def password_valid(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        return v
    
    @field_validator("role")
    @classmethod
    def role_valid(cls, v):
        valid_roles = ["customer", "technician", "admin"]
        if v not in valid_roles:
            raise ValueError(f"Role must be one of {valid_roles}")
        return v

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: dict

class UserResponse(BaseModel):
    id: str
    email: str
    role: str
    created_at: str

# ============= DATABASE MODELS & CONNECTION =============
Base = declarative_base()

class Account(Base):
    __tablename__ = "accounts"
    
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(50), nullable=False, default="customer")
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

# SQLAlchemy Engine and Session
engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)
async_session_maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Dependency for getting database session"""
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def init_db():
    """Initialize database tables"""
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("✓ Database tables initialized successfully")
    except Exception as e:
        logger.error(f"✗ Failed to initialize database: {e}")
        raise

# ============= HELPER FUNCTIONS =============
async def log_event(service: str, event: str, level: str, message: str):
    """Send log to Logging Service (non-blocking)"""
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            await client.post(
                f"{LOGGING_SERVICE_URL}/log",
                json={
                    "service": service,
                    "event": event,
                    "level": level,
                    "message": message,
                    "timestamp": datetime.utcnow().isoformat()
                }
            )
    except Exception as e:
        logger.warning(f"Failed to log event: {e}")

def hash_password(password: str) -> str:
    """Hash password using bcrypt"""
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, password_hash: str) -> bool:
    """Verify password against hash"""
    return bcrypt.checkpw(password.encode(), password_hash.encode())

def create_access_token(email: str, role: str, user_id: str) -> str:
    """Create JWT token"""
    payload = {
        "email": email,
        "role": role,
        "user_id": user_id,
        "exp": datetime.utcnow() + timedelta(hours=JWT_EXPIRATION_HOURS),
        "iat": datetime.utcnow()
    }
    token = jwt.encode(payload, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)
    return token

def verify_token(token: str) -> dict:
    """Verify JWT token"""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# ============= LIFESPAN & APP =============
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager for startup and shutdown"""
    # Startup
    logger.info("Starting Authorization Service...")
    await init_db()
    logger.info("[OK] Authorization Service started successfully")
    yield
    # Shutdown
    logger.info("Shutting down Authorization Service...")
    await engine.dispose()
    logger.info("[OK] Database connections closed")

# Create FastAPI app with lifespan
app = FastAPI(title="Authorization Service", version="1.0.0", lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[FRONTEND_URL, "http://localhost:3000", "http://localhost:8001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============= ENDPOINTS =============
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "auth-service"}

@app.post("/register", response_model=UserResponse)
async def register(request: RegisterRequest, db: AsyncSession = Depends(get_db)):
    """Register new user (customers only - technicians must be created by admin)"""
    try:
        # Prevent direct technician or admin registration
        if request.role in ["technician", "admin"]:
            await log_event("AuthService", "register.blocked", "WARNING",
                          f"Attempted to register as {request.role} from public endpoint")
            raise HTTPException(
                status_code=403,
                detail="Cannot register as technician or admin. Please contact an administrator."
            )
        
        # Check if user already exists
        result = await db.execute(
            select(Account).where(Account.email == request.email)
        )
        existing = result.scalar_one_or_none()
        
        if existing:
            await log_event("AuthService", "register.failed", "WARNING", 
                          f"User {request.email} already exists")
            raise HTTPException(status_code=400, detail="Email already registered")
        
        # Hash password
        password_hash = hash_password(request.password)
        
        # Force role to customer for public registration
        new_user = Account(
            email=request.email,
            password_hash=password_hash,
            role="customer"
        )
        db.add(new_user)
        await db.flush()
        await db.refresh(new_user)
        
        await log_event("AuthService", "user.registered", "INFO",
                      f"User {request.email} registered as customer at {datetime.utcnow().isoformat()}")
        
        return UserResponse(
            id=str(new_user.id),
            email=new_user.email,
            role=new_user.role,
            created_at=new_user.created_at.isoformat()
        )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Registration error: {e}")
        await log_event("AuthService", "register.error", "ERROR", str(e))
        raise HTTPException(status_code=500, detail="Registration failed")

@app.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate user and return JWT token"""
    try:
        # Find user
        result = await db.execute(
            select(Account).where(Account.email == request.email)
        )
        user = result.scalar_one_or_none()
        
        if not user:
            await log_event("AuthService", "login.failed", "WARNING",
                          f"Login attempt for non-existent user: {request.email}")
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Verify password
        if not verify_password(request.password, user.password_hash):
            await log_event("AuthService", "login.failed", "WARNING",
                          f"Failed password for user: {request.email}")
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Create token
        token = create_access_token(
            email=user.email,
            role=user.role,
            user_id=str(user.id)
        )
        
        await log_event("AuthService", "login.success", "INFO",
                      f"User {request.email} (role: {user.role}) logged in at {datetime.utcnow().isoformat()}")
        
        return TokenResponse(
            access_token=token,
            token_type="bearer",
            user={
                "id": str(user.id),
                "email": user.email,
                "role": user.role
            }
        )
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {e}")
        await log_event("AuthService", "login.error", "ERROR", str(e))
        raise HTTPException(status_code=500, detail="Login failed")

@app.post("/verify")
async def verify_email(email: EmailStr, code: str, db: AsyncSession = Depends(get_db)):
    """Verify email (optional feature)"""
    try:
        # TODO: Check verification code (implement email service)
        result = await db.execute(
            select(Account).where(Account.email == email)
        )
        user = result.scalar_one_or_none()
        
        if user:
            user.is_verified = True
            await db.flush()
            
            await log_event("AuthService", "email.verified", "INFO",
                          f"Email verified for {email}")
            
            return {"message": "Email verified successfully"}
        else:
            raise HTTPException(status_code=404, detail="User not found")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Verification error: {e}")
        raise HTTPException(status_code=500, detail="Verification failed")

@app.get("/public_key")
async def get_public_key():
    """Get public key for token verification"""
    # For HS256, this is just the algorithm info
    return {
        "algorithm": JWT_ALGORITHM,
        "key_type": "symmetric"
    }

@app.post("/validate-token")
async def validate_token(token: str = Header(..., alias="Authorization")):
    """Validate JWT token (used by other services)"""
    try:
        # Remove "Bearer " prefix
        if token.startswith("Bearer "):
            token = token[7:]
        
        payload = verify_token(token)
        return {"valid": True, "payload": payload}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid token")

# ============= ADMIN ENDPOINTS =============
@app.get("/admin/users")
async def get_all_users(
    authorization: str = Header(...),
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """Get all users (admin only)"""
    try:
        user = verify_token(authorization.replace("Bearer ", ""))
        
        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Admin access required")
        
        result = await db.execute(
            select(Account)
            .order_by(Account.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        users = result.scalars().all()
        
        await log_event("AuthService", "admin.view_users", "INFO",
                      f"Admin {user.get('email')} viewed user list at {datetime.utcnow().isoformat()}")
        
        return [
            {
                "id": str(u.id),
                "email": u.email,
                "role": u.role,
                "is_verified": u.is_verified,
                "created_at": u.created_at.isoformat()
            }
            for u in users
        ]
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Get users error: {e}")
        raise HTTPException(status_code=500, detail="Failed to retrieve users")

@app.post("/admin/users/create-technician")
async def create_technician(
    request: RegisterRequest,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Create technician account (admin only)"""
    try:
        user = verify_token(authorization.replace("Bearer ", ""))
        
        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Admin access required")
        
        # Check if user already exists
        result = await db.execute(
            select(Account).where(Account.email == request.email)
        )
        existing = result.scalar_one_or_none()
        
        if existing:
            raise HTTPException(status_code=400, detail="Email already registered")
        
        # Hash password
        password_hash = hash_password(request.password)
        
        # Create technician
        new_technician = Account(
            email=request.email,
            password_hash=password_hash,
            role="technician"
        )
        db.add(new_technician)
        await db.flush()
        await db.refresh(new_technician)
        
        await log_event("AuthService", "admin.create_technician", "INFO",
                      f"Admin {user.get('email')} created technician account {request.email} at {datetime.utcnow().isoformat()}")
        
        return {
            "id": str(new_technician.id),
            "email": new_technician.email,
            "role": new_technician.role,
            "created_at": new_technician.created_at.isoformat()
        }
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Create technician error: {e}")
        raise HTTPException(status_code=500, detail="Failed to create technician")

@app.put("/admin/users/{user_id}/role")
async def change_user_role(
    user_id: str,
    new_role: str,
    authorization: str = Header(...),
    db: AsyncSession = Depends(get_db)
):
    """Change user role (admin only)"""
    try:
        admin_user = verify_token(authorization.replace("Bearer ", ""))
        
        if admin_user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Admin access required")
        
        # Validate role
        if new_role not in ["customer", "technician", "admin"]:
            raise HTTPException(status_code=400, detail="Invalid role")
        
        # Find user
        result = await db.execute(
            select(Account).where(Account.id == uuid.UUID(user_id))
        )
        target_user = result.scalar_one_or_none()
        
        if not target_user:
            raise HTTPException(status_code=404, detail="User not found")
        
        old_role = target_user.role
        target_user.role = new_role
        await db.flush()
        
        await log_event("AuthService", "admin.change_role", "INFO",
                      f"Admin {admin_user.get('email')} changed {target_user.email} role from {old_role} to {new_role} at {datetime.utcnow().isoformat()}")
        
        return {
            "id": str(target_user.id),
            "email": target_user.email,
            "old_role": old_role,
            "new_role": new_role,
            "updated_at": datetime.utcnow().isoformat()
        }
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Change role error: {e}")
        raise HTTPException(status_code=500, detail="Failed to change user role")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)