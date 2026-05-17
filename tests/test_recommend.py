import pytest

def test_recommend_success(test_client, mock_recommender):
    """
    Test successful recommendation fetching by book_id
    """
    response = test_client.get("/recommend?book_id=book_1&top_k=5")
    
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 2
    assert data[0]["id"] == "book_2"
    
    # Verify the mock was called correctly
    mock_recommender.get_book.assert_called_once_with("book_1")
    mock_recommender.recommend.assert_called_once_with(book_id="book_1", top_k=5)

def test_recommend_book_not_found(test_client, mock_recommender):
    """
    Test recommendation when the requested book is not found in the dataset
    """
    mock_recommender.get_book.return_value = None
    
    response = test_client.get("/recommend?book_id=invalid_book")
    
    assert response.status_code == 404
    assert response.json()["detail"] == "Book not found"
    mock_recommender.get_book.assert_called_once_with("invalid_book")

def test_recommend_me_success_dev_auth(test_client, mock_recommender, mock_firebase, mocker):
    """
    Test personalized recommendations using X-Dev-Uid bypass
    """
    mock_settings = mocker.Mock()
    mock_settings.dev_auth_bypass = True
    mocker.patch('app.api.routes.settings', mock_settings)
    response = test_client.get(
        "/recommend/me?top_k=5", 
        headers={"X-Dev-Uid": "dev_user_1"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 2
    assert data[0]["id"] == "book_4"
    
    # Verify Firebase mock was called
    mock_firebase.get_user_history.assert_called_once_with("dev_user_1", limit=200)
    
    # Verify recommend_for_user was called with correct exclude_book_ids (history_book_2 is borrowing)
    mock_recommender.recommend_for_user.assert_called_once()
    call_kwargs = mock_recommender.recommend_for_user.call_args.kwargs
    assert call_kwargs["top_k"] == 5
    assert "history_book_2" in call_kwargs["exclude_book_ids"]
    assert "history_book_1" not in call_kwargs["exclude_book_ids"] # returned, so not excluded

def test_recommend_me_success_bearer_auth(test_client, mock_recommender, mock_firebase):
    """
    Test personalized recommendations using Bearer token
    """
    # Assuming the app has dev auth enabled but we don't pass X-Dev-Uid, 
    # it should fall back to Bearer check
    response = test_client.get(
        "/recommend/me?top_k=5", 
        headers={"Authorization": "Bearer some_token"}
    )
    
    assert response.status_code == 200
    # Our conftest mocks verify_firebase_id_token to return {"uid": "test_uid"}
    mock_firebase.get_user_history.assert_called_once_with("test_uid", limit=200)

def test_recommend_me_missing_auth(test_client):
    """
    Test /recommend/me fails when no auth headers are provided
    """
    response = test_client.get("/recommend/me?top_k=5")
    
    assert response.status_code == 401
    assert "Missing Authorization" in response.json()["detail"]

def test_recommend_me_firebase_inactive(test_client, mock_recommender, mock_firebase):
    """
    Test 503 response if Firebase is inactive
    """
    mock_firebase.active = False
    
    response = test_client.get(
        "/recommend/me?top_k=5", 
        headers={"X-Dev-Uid": "dev_user_1"}
    )
    
    assert response.status_code == 503
    assert response.json()["detail"] == "Firebase is not available"
