from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
import os

app = FastAPI()

# Configuration:
FILE_DIRECTORY = "/apps/security"  # Replace with the path to your folder containing the files


@app.get("/files/{filename}")
async def get_file(filename: str):
    """
    Returns the specified file from the data directory.

    Args:
        filename: The name of the file to retrieve.

    Raises:
        HTTPException 404: If the file does not exist.
    """

    file_path = os.path.join(FILE_DIRECTORY, filename)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail=f"File '{filename}' not found")

    return FileResponse(
        path=file_path,
        filename=filename  # Use the requested filename for the download
    )

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)