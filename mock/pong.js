
var canvas = document.getElementById('game-canvas')
var ctx = canvas.getContext('2d')

class Entity{    
    update(){}
    render(){}    
}

class Ball extends Entity{    
    constructor(radius, position){
        super()
        this.radius = radius
        this.position = position || { x: 0, y:0 }
        this.speed = { x: 2, y: -2}
    }

    update(){
        const nx = this.position.x + this.speed.x
        const ny = this.position.y + this.speed.y
    
        if ((nx < this.radius) || (nx > canvas.width - this.radius))
        this.speed.x = -this.speed.x
    
        if ((ny < this.radius) || (ny > canvas.height - this.radius))
        this.speed.y = -this.speed.y
            
        this.position.x += this.speed.x
        this.position.y += this.speed.y    
    }

    render(){
        ctx.beginPath()        
        ctx.arc(
            this.position.x, 
            this.position.y, 
            this.radius, 0, Math.PI*2)
        ctx.fillStyle = '#fff'
        ctx.fill()
        ctx.closePath()
    }
}

class Player extends Entity{
    constructor(size){
        super()
        this.size = size || { w : 5, h: 25}
        this.position = {x:0, y:0}
        this.resetPosition()
        this.speed = 2
        this.score = 0
    }
    update(keys){
        if (keys){
            if (keys.up === true)
                this.position.y -= this.speed
            if (keys.down === true)
                this.position.y += this.speed
        }
        
        if (this.position.y < this.size.h /2)
            this.position.y = this.size.h /2
        if (this.position.y > canvas.height-this.size.h /2)
            this.position.y = canvas.height-this.size.h /2
    }
    render(){
        ctx.fillStyle = '#eee'
        ctx.fillRect(
            this.position.x - this.size.w/2,
            this.position.y - this.size.h/2,
            this.size.w,
            this.size.h        
        )
    }
    getBounds(){
        return {
            x1: position.x - this.size.w/2,
            y1: this.position.y - this.size.h/2,
            x2: x1 + this.size.w,
            y2: y2 + this.size.h
        }
    }
    resetPosition(){
        this.position.x = 5
        this.position.y = canvas.height / 2
    }
} 

class CPUPlayer extends Player{
    resetPosition(){
        this.position.x = canvas.width-5
        this.position.y = canvas.height / 2
    }
}

class PlayField extends Entity{
    render(){        
        ctx.lineWidth = 2;
        ctx.strokeStyle = "#222"
        
        ctx.setLineDash([4, 0])
        ctx.beginPath();
        ctx.moveTo(canvas.width/2.0, 1.0)
        ctx.lineTo(canvas.width/2.0, canvas.height)
        ctx.stroke()        

        ctx.beginPath();
        ctx.moveTo(0, canvas.height /2)
        ctx.lineTo(canvas.width, canvas.height /2)
        ctx.stroke()        
    }
}

class HUD extends Entity{
    render(state){
        ctx.font = "12px Courier New";
        ctx.fillText(`SCORE ${state.score.player}`, 5, 15);

    }
}

const GameState = {    
    waiting: 0,
    paused : 1,
    running: 2    
}

class Game extends Entity{
    constructor(){
        super()
        this.field = new PlayField(),
        this.ball = new Ball(4, {x: canvas.width / 2, y: canvas.height /2})
        this.player = new Player()
        this.adversary = new CPUPlayer()
        this.hud = new HUD()
        this.keys = {
            enter: false,
            up: false,
            down: false
        }
        this.addEventListeners()
        this.state = GameState.waiting
    }
    render(){
        ctx.clearRect(0, 0, canvas.width, canvas.height)
        this.field.render()
        this.player.render()
        this.adversary.render()
        this.ball.render()
        this.hud.render({
            game: this.game,
            score:{
                player: this.player.score,
                adversary: this.adversary.score
            }
        })
    }
    update(){        
        switch(this.state){
            case GameState.running:
                this.ball.update()
                this.player.update(this.keys)
            break
        }        

    }
    addEventListeners(){
        document.addEventListener('keydown', (e)=>{
            switch(e.key){                
                case 'Enter':
                    this.keys.enter = true
                    break
                case 'ArrowUp':
                    this.keys.up = true
                    break
                case 'ArrowDown':
                    this.keys.down = true
                    break;
            }
        })
        
        document.addEventListener('keyup', (e)=>{
            switch(e.key){
                case 'Enter':
                    this.keys.enter = false
                    break
                case 'ArrowUp':
                    this.keys.up = false
                    break
                case 'ArrowDown':
                    this.keys.down = false
                    break;
            }
        })
    }
}

const game = new Game()



function loop(){        
    game.update()
    game.render()    
    requestAnimationFrame(loop)
}
requestAnimationFrame(loop)
