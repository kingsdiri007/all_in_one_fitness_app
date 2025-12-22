from flask import Blueprint, request, jsonify
from app import db
from app.models import CalendarEvent, User
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime, timedelta

calendar_bp = Blueprint('calendar', __name__, url_prefix='/api/calendar')


@calendar_bp.route('/events', methods=['GET'])
@jwt_required()
def get_calendar_events():
    """Get user's calendar events with optional date range"""
    user_id = get_jwt_identity()
    
    # Query params
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    
    query = CalendarEvent.query.filter_by(user_id=user_id)
    
    if start_date:
        query = query.filter(CalendarEvent.date >= datetime.fromisoformat(start_date).date())
    if end_date:
        query = query.filter(CalendarEvent.date <= datetime.fromisoformat(end_date).date())
    
    events = query.order_by(CalendarEvent.date, CalendarEvent.start_time).all()
    
    return jsonify({
        'events': [e.to_dict() for e in events]
    }), 200


@calendar_bp.route('/events/week', methods=['GET'])
@jwt_required()
def get_week_events():
    """Get events for current week"""
    user_id = get_jwt_identity()
    
    today = datetime.utcnow().date()
    week_start = today - timedelta(days=today.weekday())
    week_end = week_start + timedelta(days=6)
    
    events = CalendarEvent.query.filter(
        CalendarEvent.user_id == user_id,
        CalendarEvent.date >= week_start,
        CalendarEvent.date <= week_end
    ).order_by(CalendarEvent.date, CalendarEvent.start_time).all()
    
    return jsonify({
        'week_start': week_start.isoformat(),
        'week_end': week_end.isoformat(),
        'events': [e.to_dict() for e in events]
    }), 200


@calendar_bp.route('/events/<int:event_id>', methods=['GET'])
@jwt_required()
def get_event_detail(event_id):
    """Get specific event details"""
    user_id = get_jwt_identity()
    
    event = CalendarEvent.query.filter_by(
        id=event_id,
        user_id=user_id
    ).first_or_404()
    
    return jsonify({
        'event': event.to_dict()
    }), 200


@calendar_bp.route('/events/<int:event_id>/complete', methods=['PATCH'])
@jwt_required()
def complete_event(event_id):
    """Mark event as completed"""
    user_id = get_jwt_identity()
    
    event = CalendarEvent.query.filter_by(
        id=event_id,
        user_id=user_id
    ).first_or_404()
    
    try:
        event.completed = True
        event.completed_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'message': 'Event marked as completed',
            'event': event.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to complete event', 'details': str(e)}), 500


@calendar_bp.route('/events', methods=['POST'])
@jwt_required()
def create_event():
    """Create a custom calendar event"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    if not data or not data.get('title') or not data.get('date'):
        return jsonify({'error': 'title and date are required'}), 400
    
    try:
        event = CalendarEvent(
            user_id=user_id,
            title=data['title'],
            description=data.get('description'),
            date=datetime.fromisoformat(data['date']).date(),
            start_time=datetime.strptime(data['start_time'], '%H:%M').time() if data.get('start_time') else None,
            duration_minutes=data.get('duration_minutes', 60),
            exercises=data.get('exercises')
        )
        db.session.add(event)
        db.session.commit()
        
        return jsonify({
            'message': 'Event created',
            'event': event.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to create event', 'details': str(e)}), 500


@calendar_bp.route('/events/<int:event_id>', methods=['DELETE'])
@jwt_required()
def delete_event(event_id):
    """Delete a calendar event"""
    user_id = get_jwt_identity()
    
    event = CalendarEvent.query.filter_by(
        id=event_id,
        user_id=user_id
    ).first_or_404()
    
    try:
        db.session.delete(event)
        db.session.commit()
        
        return jsonify({'message': 'Event deleted'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Failed to delete event', 'details': str(e)}), 500